#!/usr/bin/env bash

# no GPU behind the VNC display; let Mesa do it in software
export LIBGL_ALWAYS_SOFTWARE=1
export QT_QPA_PLATFORM=xcb
export LANG=C.UTF-8

# if Qt Quick still misbehaves under llvmpipe, try uncommenting this
# export QT_QUICK_BACKEND=software

# add the bind-mounted files directory to the Qt file dialog sidebar
FILES_DIR="${MUSESCORE_FILES_DIR:-/musescore-files}"
if [[ -d "${FILES_DIR}" ]]; then
  QT_CONF="${XDG_CONFIG_HOME:-${HOME}/.config}/QtProject.conf"
  SHORTCUT="file://${FILES_DIR}"
  mkdir -p "$(dirname "${QT_CONF}")"
  if ! grep -qs '^\[FileDialog\]' "${QT_CONF}"; then
    printf '[FileDialog]\nshortcuts=file:, %s, file://%s\nsidebarWidth=150\n\n' "${SHORTCUT}" "${HOME}" >> "${QT_CONF}"
  else
    if ! grep -q '^shortcuts=' "${QT_CONF}"; then
      sed -i "/^\[FileDialog\]/a shortcuts=file:, ${SHORTCUT}, file://${HOME}" "${QT_CONF}"
    elif ! grep -q "^shortcuts=.*${SHORTCUT}\(,\|\$\)" "${QT_CONF}"; then
      sed -i "s|^shortcuts=.*|&, ${SHORTCUT}|" "${QT_CONF}"
    fi
    # Qt skips the saved shortcuts entirely unless sidebarWidth is present
    if ! grep -q '^sidebarWidth=' "${QT_CONF}"; then
      sed -i "/^\[FileDialog\]/a sidebarWidth=150" "${QT_CONF}"
    fi
  fi
fi

# MuseScore polls the ALSA sequencer for MIDI ports; there isn't one in here
exec /opt/musescore/AppRun "$@" 2> >(grep -v --line-buffered 'snd_seq_hw_open' >&2)
