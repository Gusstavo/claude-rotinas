#!/usr/bin/env bash
# Imprime "url sha" de cada PR que precisa de review meu agora. Sem saída =
# nada novo = o Claude não é chamado. Entra o PR que:
#   - está aberto, fora de draft, com review pedido a mim (direto ou por time);
#   - não tem review meu aprovado (aprovei uma vez, não revejo);
#   - se já tem review meu enviado, me pediu review de novo depois (o GitHub me
#     tira de requested_reviewers quando eu reviso e me põe de volta no re-pedido);
#   - não tem rascunho meu pendente (o anterior ainda espera eu publicar);
#   - não foi visto por esta rotina neste mesmo commit.
set -euo pipefail

me=$(gh api user --jq .login)

gh search prs --review-requested=@me --state=open --draft=false --limit 100 \
  --json url,repository,number --jq '.[] | "\(.url) \(.repository.nameWithOwner) \(.number)"' |
while read -r url repo n; do
  pr=$(gh api "repos/$repo/pulls/$n" \
    --jq "[.head.sha, .draft, ([.requested_reviewers[].login] | index(\"$me\") != null)] | @tsv")
  IFS=$'\t' read -r sha draft requested_direct <<<"$pr"
  [[ "$draft" == false ]] || continue

  # Meus reviews, em ordem: último estado enviado e se há rascunho pendente.
  mine=$(gh api "repos/$repo/pulls/$n/reviews" --paginate \
    --jq "[.[] | select(.user.login == \"$me\") | .state]" | jq -s 'add // []')
  last_sent=$(jq -r '[.[] | select(. != "PENDING" and . != "DISMISSED")] | last // ""' <<<"$mine")
  pending=$(jq -r 'index("PENDING") != null' <<<"$mine")

  [[ "$last_sent" == APPROVED ]] && continue
  [[ "$pending" == true ]] && continue
  [[ -n "$last_sent" && "$requested_direct" != true ]] && continue

  grep -qxF "$url $sha" "$ROTINA_STATE" || echo "$url $sha"
done
