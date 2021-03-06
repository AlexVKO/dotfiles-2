
-- Window management

local grid = require "hs.grid"
grid.setMargins('20,20')
grid.setGrid('4x4')

-- Helper functions {{{1

-- Keep windows anchored at the bottom {{{2
local function snapToBottom(win, cell, screen)
    local newCell =
        hs.geometry(cell.x, grid.GRIDHEIGHT - cell.h, cell.w, cell.h)
    grid.set(win, newCell, screen)
end-- }}}2

-- Keep windows anchored at the top {{{2
local function snapToTop(win, cell, screen)
    local newCell =
        hs.geometry(cell.x, 0, cell.w, cell.h)
    grid.set(win, newCell, screen)
end-- }}}2

-- Keep windows anchored to the left {{{2
local function snapLeft(win, cell, screen)
    local newCell =
        hs.geometry(0, cell.y, cell.w, cell.h)
    grid.set(win, newCell, screen)
end-- }}}2

-- Keep windows anchored to the right {{{2
local function snapRight(win, cell, screen)
    local newCell =
        hs.geometry(grid.GRIDWIDTH - cell.w, cell.y, cell.w, cell.h)
    grid.set(win, newCell, screen)
end-- }}}2

-- Compensate for the double margin between windows {{{2
local function compensateMargins()
    local win = hs.window.focusedWindow()
    local cell = grid.get(win)
    local frame = win:frame()
    if cell.h < grid.GRIDHEIGHT and cell.h % 1 == 0 then
        if cell.y ~= 0 then
            frame.h = frame.h + grid.MARGINY / 2
            frame.y = frame.y - grid.MARGINY / 2
            win:setFrame(frame)
        end
        if cell.y + cell.h ~= grid.GRIDHEIGHT then
            frame.h = frame.h + grid.MARGINX / 2
            win:setFrame(frame)
        end
    end
    if cell.w < grid.GRIDWIDTH and cell.w % 1 == 0 then
        if cell.x ~= 0 then
            frame.w = frame.w + grid.MARGINY / 2
            frame.x = frame.x - grid.MARGINY / 2
            win:setFrame(frame)
        end
        if cell.x + cell.w ~= grid.GRIDWIDTH then
            frame.w = frame.w + grid.MARGINY / 2
            win:setFrame(frame)
        end
    end
end-- }}}2

-- Hide Finder's sidebar when the window is too narrow {{{2
function resizeFinderW(cell)
    local app = hs.application.frontmostApplication()
    if app:name() == "Finder" then
        if cell.w == 2 and not grow then
            app:selectMenuItem({"Visualizar", "Ocultar Barra Lateral"})
            -- app:selectMenuItem({"View", "Hide Sidebar"}) -- In english
        else
            app:selectMenuItem({"Visualizar", "Mostrar Barra Lateral"})
            -- app:selectMenuItem({"View", "Show Sidebar"}) -- In english
        end
    end
end-- }}}2

-- Hide Finder's toolbar when the window is too short {{{2
function resizeFinderH(cell)
    local app = hs.application.frontmostApplication()
    if app:name() == "Finder" then
        if cell.h == 2 and not grow then
            app:selectMenuItem({"Visualizar", "Ocultar Barra de Ferramentas"})
            -- app:selectMenuItem({"View", "Hide Toolbar"})
            app:selectMenuItem({"Visualizar", "Ocultar Barra de Estado"})
            -- app:selectMenuItem({"View", "Hide Status Bar"})
        else
            app:selectMenuItem({"Visualizar", "Mostrar Barra de Ferramentas"})
            -- app:selectMenuItem({"View", "Show Status Bar"})
            app:selectMenuItem({"Visualizar", "Mostrar Barra de Estado"})
            -- app:selectMenuItem({"View", "Show Status Bar"})
        end
    end
end-- }}}2

-- }}}1

-- Bindings {{{1

hs.hotkey.bind(super, ';', grid.maximizeWindow)

-- Move windows {{{2

hs.hotkey.bind(super, 'Left', function()-- {{{3
    grid.pushWindowLeft()
    compensateMargins()
end)-- }}}3

hs.hotkey.bind(super, 'Down', function()-- {{{3
    grid.pushWindowDown()
    compensateMargins()
end)-- }}}3

hs.hotkey.bind(super, 'Up', function()-- {{{3
    grid.pushWindowUp()
    compensateMargins()
end)-- }}}3

hs.hotkey.bind(super, 'Right', function()-- {{{3
    grid.pushWindowRight()
    compensateMargins()
end)-- }}}3

-- }}}2

-- Resize windows {{{2

hs.hotkey.bind(super, 'J', function()-- {{{3
    local win = hs.window.focusedWindow()
    local cell = grid.get(win)
    local screen = win:screen()
    if cell.y < grid.GRIDHEIGHT - cell.h then
        snapToBottom(win, cell, screen)
        compensateMargins()
        return
    end
    if cell.h <= 1 then
        grow = true
    elseif cell.h >= grid.GRIDHEIGHT then
        grow = false
    end
    resizeFinderH(cell)
    if grow then
        grid.resizeWindowTaller()
    else
        grid.resizeWindowShorter()
    end
    local cell = grid.get(win)
    snapToBottom(win, cell, screen)
    compensateMargins()
end)-- }}}3

hs.hotkey.bind(super, 'K', function()-- {{{3
    local win = hs.window.focusedWindow()
    local cell = grid.get(win)
    local screen = win:screen()
    if cell.y > 0 then
        snapToTop(win, cell, screen)
        compensateMargins()
        return
    end
    if cell.h <= 1 then
        grow = true
    elseif cell.h >= grid.GRIDHEIGHT then
        grow = false
    end
    resizeFinderH(cell)
    if grow then
        grid.resizeWindowTaller()
    else
        grid.resizeWindowShorter()
    end
    local cell = grid.get(win)
    snapToTop(win, cell, screen)
    compensateMargins()
end)-- }}}3

hs.hotkey.bind(super, 'H', function()-- {{{3
    local win = hs.window.focusedWindow()
    local cell = grid.get(win)
    local screen = win:screen()
    if cell.x > 0 then
        snapLeft(win, cell, screen)
        compensateMargins()
        return
    end
    if cell.w <= 1 then
        grow = true
    elseif cell.w >= grid.GRIDWIDTH then
        grow = false
    end
    resizeFinderW(cell)
    if grow then
        grid.resizeWindowWider()
    else
        grid.resizeWindowThinner()
    end
    local cell = grid.get(win)
    snapLeft(win, cell, screen)
    compensateMargins()
end)-- }}}3

hs.hotkey.bind(super, 'L', function()-- {{{3
    local win = hs.window.focusedWindow()
    local cell = grid.get(win)
    local screen = win:screen()
    if cell.x < grid.GRIDWIDTH - cell.w then
        snapRight(win, cell, screen)
        compensateMargins()
        return
    end
    if cell.w <= 1 then
        grow = true
    elseif cell.w >= grid.GRIDWIDTH then
        grow = false
    end
    resizeFinderW(cell)
    if grow then
        grid.resizeWindowWider()
    else
        grid.resizeWindowThinner()
    end
    local cell = grid.get(win)
    snapRight(win, cell, screen)
    compensateMargins()
end)-- }}}3

-- }}}2

-- }}}1

