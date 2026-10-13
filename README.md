# claude-rotinas

Rotinas do Claude Code agendadas **localmente no Linux**, via timers de usuário do systemd.

- Rodam sozinhas depois do boot, sem precisar abrir nada.
- Se o PC estava desligado no horário, rodam assim que ele liga.
- Um `gate.sh` opcional faz uma checagem barata antes. Se não há nada novo, o Claude nem é chamado.
- Cada execução vira uma sessão com nome no `/resume` e pode ser reaberta com `rotina continuar`.

## Instalação

```bash
git clone git@github.com:Gusstavo/claude-rotinas.git ~/claude-rotinas
~/claude-rotinas/install.sh
```

Requisitos: `claude` (logado), `gh` (logado) e systemd. `notify-send` é opcional.

## Uso

```bash
rotina list                 # rotinas, agenda e próxima execução
rotina new <nome>           # cria (abre o editor) e agenda
rotina edit <nome>          # muda prompt, agenda, ferramentas ou gate e reaplica
rotina run <nome>           # roda agora
rotina logs <nome> [-f]     # log da execução
rotina continuar <nome>     # abre a última execução no claude para seguir a conversa
rotina pause|resume <nome>  # desliga/religa sem apagar
rotina rm <nome>            # remove (vai para ~/rotinas/.lixeira)
rotina sync                 # reaplica tudo após editar arquivos à mão
```

## Estrutura de uma rotina

As rotinas ficam em `~/rotinas/<nome>/`, fora deste repo, porque os prompts podem ter coisas privadas. Para guardar em outro lugar, exporte `ROTINAS_DIR` no `~/.profile`.

| Arquivo | Para quê |
|---|---|
| `prompt.md` | O que o Claude faz. É lido a cada execução, então editar não exige `sync`. |
| `rotina.conf` | `SCHEDULE` (formato OnCalendar), `DIR` (onde o claude roda), `TOOLS` (ferramentas liberadas), `MODE`, `NOTIFY`, `SESSAO`. |
| `gate.sh` | Opcional. Imprime os itens novos; sem saída, a execução é pulada. O que ele imprime vai para o prompt e, depois de um sucesso, para `$ROTINA_STATE`, onde o gate pode consultar o que já foi feito. |
| `saidas/` | Resultado de cada execução, com o ID da sessão no topo. |

Exemplos de `SCHEDULE` (teste com `systemd-analyze calendar "<expr>"`):

- `*:0/15`: a cada 15 minutos
- `hourly`: de hora em hora
- `Mon..Fri 08:45`: dias úteis às 8h45

Veja `exemplos/review-prs`: um review dos PRs em que você foi marcado como revisor, que só chama o Claude quando há PR novo ou commit novo.

## Credenciais

As rotinas podem rodar sem você logado no sistema, então o `gh` precisa conseguir ler o token. Se `gh auth status` mostrar que o token está no keyring, as rotinas só funcionam depois do login. Para evitar isso, rode `gh auth login --insecure-storage`.
