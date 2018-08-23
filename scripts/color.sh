export TERM=xterm-256color

sbold=$(tput bold)
snormal=$(tput sgr0)

function bold {
  echo "${sbold}$*${snormal}"
}
