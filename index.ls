start = null
is-blink = false
is-light = true
is-run = false
is-show = true
is-warned = false
handler = null
latency = 0
stop-by = null
delay = 60000
audio-remind = null
audio-end = null
ripple-canvas = null
ripple-ctx = null
ripple-radius = 0
ripple-speed = 2
ripple-max = 0
ripple-req = null
timer-el = null
fbtns = null
bind-buttons = null

new-audio = (file) ->
  node = new Audio!
    ..src = file
    ..loop = false
    ..load!
  document.body.appendChild node
  return node

sound-toggle = (des, state) ->
  if state => des.play!
  else des
    ..currentTime = 0
    ..pause!

show = ->
  is-show := !is-show
  if fbtns =>
    fbtns.forEach (btn) ->
      btn.style.opacity = if is-show => \1.0 else \0.1

adjust = (it,v) ->
  if is-blink => return
  delay := delay + it * 1000
  if it==0 => delay := v * 1000
  if delay <= 0 => delay := 0
  if timer-el => timer-el.textContent = delay
  resize!

toggle = ->
  is-run := !is-run
  document.getElementById(\toggle).textContent = if is-run => "STOP" else "RUN"
  if !is-run and handler => 
    stop-by := new Date!
    clearInterval handler
    handler := null
    sound-toggle audio-end, false
    sound-toggle audio-remind, false
    stop-ripple!
  if stop-by =>
    latency := latency + (new Date!)getTime! - stop-by.getTime!
  if is-run => run!

reset = ->
  if delay == 0 => delay := 1000
  sound-toggle audio-remind, false
  sound-toggle audio-end, false
  stop-by := 0
  is-warned := false
  is-blink := false
  latency := 0
  start := null #new Date!
  is-run := true
  toggle!
  if handler => clearInterval handler
  handler := null
  if timer-el =>
    timer-el.textContent = delay
    timer-el.style.color = \#fff
  stop-ripple!
  resize!


blink = ->
  is-blink := true
  is-light := !is-light
  if timer-el => timer-el.style.color = if is-light => \#fff else \#f00

count = ->
  tm = timer-el
  diff = start.getTime! - (new Date!)getTime! + delay + latency
  if diff > 60000 => is-warned := false
  if diff < 60000 and !is-warned =>
    is-warned := true
    sound-toggle audio-remind, true
  if diff < 55000 => sound-toggle audio-remind, false
  if diff < 0 and !is-blink =>
    sound-toggle audio-end, true
    is-blink := true
    diff = 0
    clearInterval handler
    stop-ripple!
    handler := setInterval ( -> blink!), 500
  if tm => tm.textContent = "#{diff}"
  resize!

run =  ->
  if start == null =>
    start := new Date!
    latency := 0
    is-blink := false
  if handler => clearInterval handler
  if is-blink => handler := setInterval (-> blink!), 500
    stop-ripple!
  else
    start-ripple!
    handler := setInterval (-> count!), 100

resize = ->
  tm = timer-el
  w = if tm => tm.getBoundingClientRect!width else window.innerWidth
  h = window.innerHeight
  len = if tm and tm.textContent => tm.textContent.length else 3
  len>?=3
  if tm =>
    tm.style.fontSize = "#{1.5 * w/len}px"
    tm.style.lineHeight = "#{h}px"
  if ripple-canvas =>
    ripple-canvas.width = w
    ripple-canvas.height = h
    ripple-max = Math.min(w, h) / 2


draw-ripple = ->
  if !ripple-ctx or !ripple-canvas => return
  ripple-ctx.clearRect 0, 0, ripple-canvas.width, ripple-canvas.height
  ripple-ctx.beginPath!
  ripple-ctx.arc ripple-canvas.width / 2, ripple-canvas.height / 2, ripple-radius, 0, Math.PI * 2, false
  ripple-ctx.strokeStyle = 'rgba(255,255,255,0.6)'
  ripple-ctx.lineWidth = 4
  ripple-ctx.stroke!
  ripple-radius += ripple-speed
  if ripple-radius >= ripple-max
    ripple-radius := ripple-max
    ripple-speed := -Math.abs ripple-speed
  if ripple-radius <= 0
    ripple-radius := 0
    ripple-speed := Math.abs ripple-speed
  ripple-req := requestAnimationFrame -> draw-ripple!

start-ripple = ->
  if !ripple-canvas => ripple-canvas := document.getElementById \ripple
  if !ripple-canvas => return
  ripple-ctx ?= ripple-canvas.getContext \2d
  resize!
  if ripple-req => return
  ripple-radius := 0
  ripple-speed := Math.abs ripple-speed or 2
  draw-ripple!

stop-ripple = ->
  if ripple-req =>
    cancelAnimationFrame ripple-req
    ripple-req := null
  if ripple-ctx and ripple-canvas =>
    ripple-ctx.clearRect 0, 0, ripple-canvas.width, ripple-canvas.height

window.onload = ->
  timer-el := document.getElementById \timer
  fbtns := Array::slice.call document.querySelectorAll \.fbtn
  if timer-el => timer-el.textContent = delay
  bind-buttons!
  ripple-canvas := document.getElementById \ripple
  if ripple-canvas => ripple-ctx := ripple-canvas.getContext \2d
  resize!
  audio-remind := new-audio \audio/smb_warning.mp3
  audio-end := new-audio \audio/smb_mariodie.mp3
window.onresize = -> resize!

bind-buttons = ->
  adjust-buttons = Array::slice.call document.querySelectorAll '[data-adjust]'
  set-buttons = Array::slice.call document.querySelectorAll '[data-set]'
  toggle-btn = document.getElementById \toggle
  reset-btn = document.getElementById \reset
  hide-btn = document.getElementById \hide
  adjust-buttons.forEach (btn) ->
    btn.addEventListener \click, (e) ->
      e.preventDefault!
      adjust parseInt(btn.getAttribute \data-adjust, 10)
  set-buttons.forEach (btn) ->
    btn.addEventListener \click, (e) ->
      e.preventDefault!
      adjust 0, parseInt(btn.getAttribute \data-set, 10)
  if toggle-btn =>
    toggle-btn.addEventListener \click, (e) ->
      e.preventDefault!
      toggle!
  if reset-btn =>
    reset-btn.addEventListener \click, (e) ->
      e.preventDefault!
      reset!
  if hide-btn =>
    hide-btn.addEventListener \click, (e) ->
      e.preventDefault!
      show!
