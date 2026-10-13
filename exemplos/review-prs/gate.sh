#!/usr/bin/env bash
# Imprime "url sha" de cada PR aberto com review pedido a mim que ainda não foi
# revisado neste commit. Sem saída = nada novo = o Claude não é chamado.
set -euo pipefail
gh search prs --review-requested=@me --state=open --json url --jq '.[].url' |
while read -r url; do
  sha=$(gh pr view "$url" --json headRefOid --jq .headRefOid)
  grep -qxF "$url $sha" "$ROTINA_STATE" || echo "$url $sha"
done
