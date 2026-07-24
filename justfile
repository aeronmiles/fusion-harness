set dotenv-load := true

# ── fusion-harness ──────────────────────────────────────
# /fusion · /auto-validate · /opinion — fuse two frontier models (AND, not OR).
# The HOST runs on the BUILDER model: raw (non-slash) input IS the builder agent.
#
# Launch recipes:
#
#   just fh-workhorse        cheap pair on pi backends (API keys) — testing
#   just fh-sota             frontier pair on pi backends — on-camera defaults
#   just fh-workhorse-sub    architect via claude -p (subscription) + pi builder
#   just fh-sota-sub         same pattern at higher thinking
#
# Configuration flags (all optional, appendable to any recipe):
#   --architect <provider/id|alias>        plans/fuses/validates
#   --builder <provider/id|alias>          builds
#   --architect-backend pi|claude-cli      child runtime for architect-family
#   --builder-backend pi|claude-cli        child runtime for builder children
#   --architect-thinking <level>           EVERY architect-family execution
#   --builder-thinking <level>             EVERY builder execution
#                                          (levels: off|minimal|low|medium|high|xhigh|max)
#   --architect-system-prompt <text|path>  override architect worker/fusion system prompt
#   --builder-system-prompt <text|path>    override builder system prompt
#   --max-validations <n>                  /auto-validate halt cap            default 5
#   --escalate-to-validator-count <n>      validator triage from Nth failure  default 3
#   --child-timeout <seconds>              kill any child agent after N sec   default 28800 = 8h (max 86400)
#
# e.g. just fh-workhorse --architect-thinking high --builder-system-prompt ./persona.md
#      just fh-sota-sub --builder openai-codex/gpt-5.4
#
# Default prompts live in extensions/fusion-harness/{SYSTEM,USER}_PROMPT_*.md — edit to tune.
# Sessions persist per project (/tmp/fusion-harness-sessions) — /fh-reset for fresh memories.
#
# claude-cli backend prereqs: `claude` on PATH, signed in (`claude` interactively once).
# Do not use CLAUDE bare-mode flags that force API-key-only auth.

# WORKHORSE tier — the cheap pair (sonnet-5 plans · terra builds + hosts). Use for testing.
WORKHORSE_ARCHITECT := "anthropic/claude-sonnet-5"
WORKHORSE_BUILDER := "openai/gpt-5.6-terra"

# STATE-OF-THE-ART tier — the frontier, on-camera pair (fable 5 plans · sol builds + hosts).
SOTA_ARCHITECT := "anthropic/claude-fable-5"
SOTA_BUILDER := "openai/gpt-5.6-sol"

# Subscription-leaning defaults: architect on Claude Code CLI; builder still hosts on pi.
# Swap builder to an openai-codex/* model after `pi` /login openai-codex for ChatGPT usage.
SUB_ARCHITECT := "sonnet"
SUB_BUILDER := "openai/gpt-5.6-sol"

default:
    @just --list

# WORKHORSE tier — cheap pair at medium thinking. Use this for testing.
fh-workhorse *ARGS:
    pi -e extensions/fusion-harness/fusion-harness.ts \
        --model {{WORKHORSE_BUILDER}} \
        --architect {{WORKHORSE_ARCHITECT}} --builder {{WORKHORSE_BUILDER}} \
        --architect-backend pi --builder-backend pi \
        --architect-thinking medium --builder-thinking medium \
        {{ARGS}}

# STATE-OF-THE-ART tier — frontier pair at xhigh thinking. The on-camera run.
fh-sota *ARGS:
    pi -e extensions/fusion-harness/fusion-harness.ts \
        --model {{SOTA_BUILDER}} \
        --architect {{SOTA_ARCHITECT}} --builder {{SOTA_BUILDER}} \
        --architect-backend pi --builder-backend pi \
        --architect-thinking xhigh --builder-thinking xhigh \
        {{ARGS}}

# WORKHORSE + Claude Code subscription for the architect family (`claude -p`).
fh-workhorse-sub *ARGS:
    pi -e extensions/fusion-harness/fusion-harness.ts \
        --model {{SUB_BUILDER}} \
        --architect {{SUB_ARCHITECT}} --builder {{SUB_BUILDER}} \
        --architect-backend claude-cli --builder-backend pi \
        --architect-thinking medium --builder-thinking medium \
        {{ARGS}}

# SOTA thinking levels with Claude Code subscription architect.
fh-sota-sub *ARGS:
    pi -e extensions/fusion-harness/fusion-harness.ts \
        --model {{SUB_BUILDER}} \
        --architect {{SUB_ARCHITECT}} --builder {{SUB_BUILDER}} \
        --architect-backend claude-cli --builder-backend pi \
        --architect-thinking xhigh --builder-thinking xhigh \
        {{ARGS}}
