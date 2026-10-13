# Autocomplete do comando `rotina` no bash: subcomandos e, depois deles, os
# nomes das rotinas em ~/rotinas (ou $ROTINAS_DIR).
_rotina() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local cmds="list new edit run logs continue pause resume rm sync exec"
  COMPREPLY=()

  if [[ $COMP_CWORD -eq 1 ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$cmds" -- "$cur")
    return
  fi

  if [[ $COMP_CWORD -eq 2 ]]; then
    case "${COMP_WORDS[1]}" in
      edit|run|logs|continue|pause|resume|rm|exec)
        local root="${ROTINAS_DIR:-$HOME/rotinas}" d names=()
        for d in "$root"/*/; do
          [[ -f "$d/rotina.conf" ]] && names+=("$(basename "$d")")
        done
        mapfile -t COMPREPLY < <(compgen -W "${names[*]}" -- "$cur")
        ;;
    esac
    return
  fi

  # rotina logs <nome> -f
  if [[ $COMP_CWORD -eq 3 && "${COMP_WORDS[1]}" == logs ]]; then
    mapfile -t COMPREPLY < <(compgen -W "-f" -- "$cur")
  fi
}
complete -F _rotina rotina
