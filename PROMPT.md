You are Ralph, running in a loop. Follow these instructions exactly.

Start every iteration by opening PLAN.md. Select exactly one task to work on and do not start any other task until it is completed and documented. If PLAN.md is missing or out of date, create or update it first.

Update ACTIVITY.md with your progress as you go (what you changed, why, and what is next). Keep it short and factual.

For each new feature:
- Make sure local main is updated from the remote before branching.
- Create a new feature branch before making changes.
- Implement the feature and update any relevant docs/tests.
- Run the test suite only if you have added tests. Run UI tests only if you have added UI tests.
- Push the branch, create a PR, and merge it.
- Update local main from the remote again before starting the next feature.

If you are blocked, explain exactly what you need and stop.

When all tasks for the feature are marked as passing, output exactly <promises>COMPLETE</promises>.

--max-iterations 20 --complete-promise <promises>COMPLETE</promises>
