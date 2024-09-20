-- ⌘ ⌃ ⌥ ⇧

local markdowncontent = [[

# Hotkeys

## Program

| Command | Description |
| :---    |        ---: |
| --- | --- |
| cmd k | List all new or modified files |
| alt-cmd z | Show file differences that haven't been staged |

<style>

/* https://github.com/markdowncss/retro */

pre,
code {
  font-family: Menlo, Monaco, "Courier New", monospace;
}

pre {
  padding: .5rem;
  line-height: 1.25;
  overflow-x: scroll;
}

@media print {
  *,
  *:before,
  *:after {
    background: transparent !important;
    color: #000 !important;
    box-shadow: none !important;
    text-shadow: none !important;
  }

  a,
  a:visited {
    text-decoration: underline;
  }

  a[href]:after {
    content: " (" attr(href) ")";
  }

  abbr[title]:after {
    content: " (" attr(title) ")";
  }

  a[href^="#"]:after,
  a[href^="javascript:"]:after {
    content: "";
  }

  pre,
  blockquote {
    border: 1px solid #999;
    page-break-inside: avoid;
  }

  thead {
    display: table-header-group;
  }

  tr,
  img {
    page-break-inside: avoid;
  }

  img {
    max-width: 100% !important;
  }

  p,
  h2,
  h3 {
    orphans: 3;
    widows: 3;
  }

  h2,
  h3 {
    page-break-after: avoid;
  }
}

a,
a:visited {
  color: #01ff70;
}

a:hover,
a:focus,
a:active {
  color: #2ecc40;
}

.retro-no-decoration {
  text-decoration: none;
}

html {
  font-size: 12px;
}

@media screen and (min-width: 32rem) and (max-width: 48rem) {
  html {
    font-size: 15px;
  }
}

@media screen and (min-width: 48rem) {
  html {
    font-size: 16px;
  }
}

body {
  line-height: 1.85;
}

p,
.retro-p {
  font-size: 1rem;
  margin-bottom: 1.3rem;
}

h1,
.retro-h1,
h2,
.retro-h2,
h3,
.retro-h3,
h4,
.retro-h4 {
  margin: 1.414rem 0 .5rem;
  font-weight: inherit;
  line-height: 1.42;
}

h1,
.retro-h1 {
  margin-top: 0;
  font-size: 3.998rem;
}

h2,
.retro-h2 {
  font-size: 2.827rem;
}

h3,
.retro-h3 {
  font-size: 1.999rem;
}

h4,
.retro-h4 {
  font-size: 1.414rem;
}

h5,
.retro-h5 {
  font-size: 1.121rem;
}

h6,
.retro-h6 {
  font-size: .88rem;
}

small,
.retro-small {
  font-size: .707em;
}

/* https://github.com/mrmrs/fluidity */

img,
canvas,
iframe,
video,
svg,
select,
textarea {
  max-width: 100%;
}

html,
body {
  background-color: #222;
  min-height: 100%;
}

html {
  font-size: 18px;
}

body {
  color: #fafafa;
  font-family: "Courier New";
  line-height: 1.45;
  margin: 6rem auto 1rem;
  max-width: 48rem;
  padding: .25rem;
}

pre {
  background-color: #333;
}

blockquote {
  border-left: 3px solid #01ff70;
  padding-left: 1rem;
}
</style>
]]
local htmlcontent = hs.doc.markdown.convert(markdowncontent, "gfm")

local scrollScript = [[
// Create the keydown event for the "j" key
const eventJ = new KeyboardEvent('keydown', {
  key: 'j',
  code: 'KeyJ',
  keyCode: 74, // KeyCode for "j"
  which: 74,   // Which for "j"
  bubbles: true // Allows the event to bubble up
});

// Create the keydown event for the "k" key
const eventK = new KeyboardEvent('keydown', {
  key: 'k',
  code: 'KeyK',
  keyCode: 75, // KeyCode for "k"
  which: 75,   // Which for "k"
  bubbles: true // Allows the event to bubble up
});


// Event listener for keydown
document.addEventListener('keydown', (event) => {
  if (event.key === 'j') {
    window.scrollBy(0, window.innerHeight/2);
  } else if (event.key === 'k') {
    window.scrollBy(0, -(window.innerHeight/2));
  }
});

// Event listener for keyup
document.addEventListener('keyup', (event) => {
  if (event.key === 'j' || event.key === 'k') {
    scrolling = false; // Stop scrolling when either key is released
  }
});
]]

local function JScb(result, err)
  --print("result")
  --print(dump(result))
  --print("error")
  --print(dump(err))
end

local wv = nil
--local jHK = nil
--local kHK = nil

--local function issueJ()
--  local js = [[
--  // Dispatch the event on the document
--  document.dispatchEvent(eventJ);
--  ]]
--  wv:evaluateJavaScript(js, JScb)
--end

--local function issueK()
--  local js = [[
--  // Dispatch the event on the document
--  document.dispatchEvent(eventK);
--  ]]
--  wv:evaluateJavaScript(js, JScb)
--end

function toggleShortcuts()
  --if jHK then
  --  if jHK.enabled then
  --    jHK:disable()
  --    --jHK:delete()
  --    --jHK = nil
  --  else
  --    jHK:enable()
  --  end
  --end

  --if kHK then
  --  if kHK.enabled then
  --    kHK:disable()
  --    --kHK:delete()
  --    --kHK = nil
  --  else
  --    kHK:enable()
  --  end
  --end

  if wv then
    if wv:isVisible() then
      wv:hide()
      --wv:delete(true)
      --wv = nil
    else
      wv:show()
    end
    return
  end

  local frame = hs.screen.mainScreen():frame()
  local rect = hs.geometry.rect({
    x=frame.x+frame.w*0.15/2,
    y=frame.y+frame.h*0.25/2,
    w=frame.w*0.85,
    h=frame.h*0.75,
  })

  wv = hs.webview.new(rect, {
    javaScriptEnabled=true,
    javaScriptCanOpenWindowsAutomatically=false,
    developerExtrasEnabled=true,
    suppressesIncrementalRendering=false
  })

  masks = hs.webview.windowMasks
  -- descriptions here:
  -- https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/webview/libwebview.m#L2528
  wv:windowStyle(
    masks.titled |
    masks.closable |
    masks.resizable |
    masks.utility |
    masks.nonactivating |
    masks.HUD
  )
  -- hs.drawing.windowBehaviors
  -- https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior
  wv:behaviorAsLabels({
    --'default', -- 0
    'canJoinAllSpaces', -- 1
    --'moveToActiveSpace', -- 2
    'managed', -- 4
    --'transient', -- 8
    --'stationary', -- 16
    'participatesInCycle', -- 32
    --'ignoresCycle', -- 64
    --'fullScreenPrimary', -- 128
    --'fullScreenAuxiliary', -- 256
    --'fullScreenAllowsTiling', -- 2048
    --'fullScreenDisallowsTiling', -- 4096
  })
  -- https://github.com/Hammerspoon/hammerspoon/blob/master/extensions/drawing/drawing.lua#L707
  wv:level(hs.drawing.windowLevels.overlay)
  wv:titleVisibility('hidden')
  wv:windowTitle('shortcut_keys_wv')
  wv:allowMagnificationGestures(true)
  wv:allowNewWindows(false)
  wv:allowTextEntry(true)
  --wv:allowNavigationGestures(true)
  wv:alpha(0.75)
  wv:bringToFront(true)
  wv:closeOnEscape(true)
  --wv:deleteOnClose(true)
  wv:shadow(true)

  wv:html(htmlcontent)
  --wv:html("<html><body contenteditable=\"true\">hello...</body></html>")

  local function donecb(action, webView, navID, error)
    --print(wv:estimatedProgress())
    if action == "didFinishNavigation" then
      wv:evaluateJavaScript(scrollScript, JScb)
    end
  end
  wv:navigationCallback(donecb)

  --jHK = hs.hotkey.bind({"alt"}, "j", issueJ)
  --kHK = hs.hotkey.bind({"alt"}, "k", issueK)

  wv:show()
end

