export const meta = {
  name: 'team-work',
  description: 'Coordinated agent team for a task/project: Tech Lead plans workstreams, Architects design, Developers implement, QA tests, Reviewers verify - looping fixes until clean.',
  phases: [
    { title: 'Plan' },
    { title: 'Design' },
    { title: 'Build' },
    { title: 'QA' },
    { title: 'Review' },
  ],
}

const PLAN_SCHEMA = {
  type: 'object',
  properties: {
    workstreams: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          title: { type: 'string' },
          scope: { type: 'string' },
          description: { type: 'string' },
          kind: { type: 'string', enum: ['feature', 'ui', 'layout-fix'] },
        },
        required: ['title', 'scope', 'description', 'kind'],
      },
    },
  },
  required: ['workstreams'],
}

const DESIGN_SCHEMA = {
  type: 'object',
  properties: {
    approach: { type: 'string' },
    filesTouched: { type: 'array', items: { type: 'string' } },
    risks: { type: 'string' },
  },
  required: ['approach'],
}

const QA_SCHEMA = {
  type: 'object',
  properties: {
    pass: { type: 'boolean' },
    summary: { type: 'string' },
    issues: { type: 'array', items: { type: 'string' } },
  },
  required: ['pass', 'summary'],
}

const REVIEW_SCHEMA = {
  type: 'object',
  properties: {
    pass: { type: 'boolean' },
    feedback: { type: 'string' },
    findings: { type: 'array', items: { type: 'string' } },
  },
  required: ['pass', 'feedback'],
}

const task = typeof args === 'string' ? args : (args && args.task)
if (!task) {
  throw new Error('team-work requires a task description: pass args as a string, or {task: "..."}')
}
const maxRounds = (args && args.maxRounds) || 2
// Optional: set when resuming a run whose developers were interrupted, so
// round-1 developers continue from the partial edits in the working tree.
const resumeNote = (args && args.resumeNote) || ''

// Developer agent per workstream kind - see .claude/agents/.
const DEVELOPER_BY_KIND = {
  feature: 'flutter-feature-developer-agent',
  ui: 'flutter-ui-developer-agent',
  'layout-fix': 'flutter-layout-fix-agent',
}

// Every agent turn (exact prompt + full response), returned so the caller can
// write the per-task agent log the user's global CLAUDE.md requires.
const transcript = []
async function run(prompt, opts) {
  const response = await agent(prompt, opts)
  transcript.push({ label: opts.label, agentType: opts.agentType || 'general-purpose', prompt, response })
  return response
}

phase('Plan')
log('Tech Lead is breaking the task into workstreams...')
const plan = await run(
  `You are the Tech Lead for this project. Task/project to deliver:\n\n${task}\n\n` +
  `Break this into 1 to 5 independent workstreams a small team can build concurrently. ` +
  `For a small task, a single workstream is correct - do not invent parallelism that isn't there. ` +
  `Each workstream needs a clear, non-overlapping file/area scope so concurrent developers don't clobber ` +
  `each other's edits. Follow this repo's CLAUDE.md conventions when scoping. ` +
  `Set each workstream's kind: "ui" for new screens/dialogs/widgets, "layout-fix" for overflow/alignment/` +
  `scaling/RTL bugs in existing UI, otherwise "feature" (domain/data/bloc work, or mixed). ` +
  `Plan only - do not edit files or dispatch other agents.`,
  { schema: PLAN_SCHEMA, label: 'tech-lead:plan', phase: 'Plan' }
)

log(`Plan: ${plan.workstreams.length} workstream(s) - ${plan.workstreams.map(w => w.title).join(', ')}`)

const results = await pipeline(
  plan.workstreams,
  ws => run(
    `You are the Architect for the workstream "${ws.title}", part of this project:\n${task}\n\n` +
    `Workstream scope: ${ws.scope}\nWorkstream description: ${ws.description}\n\n` +
    `This is a design step, not a review: design the implementation approach - what files/layers are ` +
    `touched, what new abstractions (if any) are needed, DI/route/l10n entries, and how it fits this ` +
    `codebase's existing clean-architecture conventions. Do not write code - report the plan only.`,
    { schema: DESIGN_SCHEMA, label: `architect:${ws.title}`, phase: 'Design', agentType: 'flutter-architect-agent' }
  ),
  async (design, ws) => {
    const developer = DEVELOPER_BY_KIND[ws.kind] || DEVELOPER_BY_KIND.feature
    let devSummary = null
    let qa = null
    let review = null
    for (let round = 1; round <= maxRounds; round++) {
      log(`[${ws.title}] round ${round}/${maxRounds}: developer implementing`)
      devSummary = await run(
        round === 1
          ? `You are the Developer for workstream "${ws.title}" (scope: ${ws.scope}). ` +
            `Architecture plan:\n${JSON.stringify(design)}\n\nImplement it, following this repo's ` +
            `CLAUDE.md and clean-architecture/bloc conventions. Report exactly what you changed.` +
            (resumeNote ? `\n\nRESUME NOTE: ${resumeNote}` : '')
          : `You are the Developer for workstream "${ws.title}". Fix this feedback, then report what you changed:\n` +
            `QA: ${qa ? JSON.stringify(qa) : 'n/a'}\nReviewer: ${review ? review.feedback : 'n/a'}`,
        { label: `developer:${ws.title}:r${round}`, phase: 'Build', agentType: developer }
      )

      log(`[${ws.title}] round ${round}/${maxRounds}: QA testing`)
      qa = await run(
        `You are QA for workstream "${ws.title}". The developer just reported:\n${devSummary}\n\n` +
        `Verify it: flutter analyze (new issues only), the existing tests for the touched features, the ` +
        `applicable docs/POS_Order_Flow_Test_Scenarios.md scenarios, and a Windows run via run-codezync-pos ` +
        `for UI changes when on a Windows host (otherwise say it wasn't visually verified). Write new tests ` +
        `only if the task explicitly asks for them. Report pass/fail with concrete findings.\n\nTask:\n${task}`,
        { schema: QA_SCHEMA, label: `qa:${ws.title}:r${round}`, phase: 'QA', agentType: 'flutter-qa-agent' }
      )

      log(`[${ws.title}] round ${round}/${maxRounds}: reviewer verifying`)
      review = await run(
        `You are the Reviewer for workstream "${ws.title}". Review the actual diff for correctness, ` +
        `convention-fit against this repo's CLAUDE.md and flutter-code-review checklist, and scope creep.\n` +
        `Developer report:\n${devSummary}\nQA report:\n${JSON.stringify(qa)}\n\n` +
        `Return pass=true only if this is mergeable as-is.`,
        { schema: REVIEW_SCHEMA, label: `reviewer:${ws.title}:r${round}`, phase: 'Review', agentType: 'flutter-code-review-agent' }
      )

      // A failed QA/review agent returns null - treat it as not passing
      // instead of crashing the whole workstream.
      if (qa && review && qa.pass && review.pass) break
    }
    return { workstream: ws, design, devSummary, qa, review }
  }
)

const settled = results.filter(Boolean)
const dropped = plan.workstreams.length - settled.length
if (dropped > 0) {
  log(`${dropped} workstream(s) failed outright and were dropped - see the run journal for the error.`)
}

return { plan, workstreams: settled, transcript }
