#!/usr/bin/env python3.7

import iterm2
import re

async def main(connection):
    app = await iterm2.async_get_app(connection)
    # This regex splits the font into its name and size. Fonts always end with
    # their size in points, preceded by a space.
    r = re.compile(r'^(.* )(\d*)$')

    @iterm2.RPC
    async def twiddle_font_size(session_id):
        session = app.get_session_by_id(session_id)
        if not session:
            return

        # Get the session's profile because we need to know its font.
        profile = await session.async_get_profile()

        # Extract the name and point size of the font using a regex.
        font = profile.normal_font

        replacement = "Monaco 13"

        if font == "Monaco 13": replacement = "Monaco 16"
        if font == "Monaco 16": replacement = "Monaco 19"

        change = iterm2.LocalWriteOnlyProfile()
        change.set_normal_font(replacement)

        # Update the session's copy of its profile without updating the
        # underlying profile.
        await session.async_set_profile_properties(change)
    await twiddle_font_size.async_register(connection)

    @iterm2.RPC
    async def shimmy_horizontal(session_id):
        session = app.get_session_by_id(session_id)
        if not session:
            return

        h = session.preferred_size.height
        w = session.preferred_size.width

        if w >= 160 or w < 80: w = 80
        elif w >= 120:         w = 160
        elif w >= 100:         w = 120
        elif w >=  90:         w = 100
        elif w >=  80:         w = 90

        size = iterm2.util.Size(w, h)

        session.preferred_size = size
        await session.tab.async_update_layout()
    await shimmy_horizontal.async_register(connection)

    @iterm2.RPC
    async def shimmy_vertical(session_id):
        session = app.get_session_by_id(session_id)
        if not session:
            return

        h = session.preferred_size.height
        w = session.preferred_size.width

        if h >= 60 or h < 25: h = 25
        elif h >= 50:         h = 60
        elif h >= 40:         h = 50
        elif h >= 25:         h = 40

        size = iterm2.util.Size(w, h)

        session.preferred_size = size
        await session.tab.async_update_layout()
    await shimmy_vertical.async_register(connection)

    @iterm2.RPC
    async def prefer_current_size(session_id):
        session = app.get_session_by_id(session_id)
        if not session:
            return

        # I don't think I should need to call this, but if I don't, grid_size
        # will be out of date.
        #
        # https://gitlab.com/gnachman/iterm2/-/issues/10642
        await app.async_refresh()

        session.preferred_size = session.grid_size

        return True
    await prefer_current_size.async_register(connection)

    @iterm2.RPC
    async def relayout_layout(session_id):
        session = app.get_session_by_id(session_id)
        if not session:
            return

        await session.tab.async_update_layout()
    await relayout_layout.async_register(connection)

iterm2.run_forever(main)
