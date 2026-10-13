#!/usr/bin/env bash
# Instala o comando `rotina` (link para este repo, então `git pull` já atualiza)
# e liga o agendamento das rotinas em ~/rotinas.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
ROOT="${ROTINAS_DIR:-$HOME/rotinas}"

for dep in claude gh systemctl; do
  command -v "$dep" >/dev/null || { echo "falta instalar: $dep" >&2; exit 1; }
done

chmod +x "$REPO/rotina" "$REPO"/exemplos/*/gate.sh
mkdir -p "$HOME/.local/bin" "$ROOT"
ln -sf "$REPO/rotina" "$HOME/.local/bin/rotina"
echo "comando instalado: ~/.local/bin/rotina"

# Autocomplete (o bash-completion carrega sob demanda desta pasta).
COMPLETIONS="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
mkdir -p "$COMPLETIONS"
ln -sf "$REPO/rotina-completion.bash" "$COMPLETIONS/rotina"
echo "autocomplete instalado: abra um terminal novo"

if [[ ! -e "$ROOT/review-prs" ]]; then
  read -rp "Copiar a rotina de exemplo review-prs para $ROOT? [s/N] " ok
  [[ "$ok" == [sS] ]] && cp -r "$REPO/exemplos/review-prs" "$ROOT/review-prs"
fi

if [[ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" != yes ]]; then
  echo "Ligando o linger (rotinas rodam no boot, mesmo sem login). Pode pedir a senha do sudo."
  sudo loginctl enable-linger "$USER"
fi

"$REPO/rotina" sync
"$REPO/rotina" list
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "Aviso: adicione ~/.local/bin ao PATH." ;; esac
