;each terminal has it's own selected frame but there is _the_ selected frame
;it's the frame that belongs to the terminal from which
;the most recent input came.
;(select-frame) can set an arbitrary frame to be the selected one without it
;actually being the case
(selected-frame)

;=(frame-parameters (selected-frame))
(frame-parameters nil)


;29.3
;!total window size occupied by things other than windows:
;border-around frame
;inner border
;fringe between windows
;menu-bar
;tool-bar

(frame-parameter nil 'height)
(frame-height)
(frame-pixel-height);do not use
(frame-parameter nil 'tty-color-mode)

;frame has:
;window
;minibuffer window;
;echo area
;menu bar
;tool bar

;windows in a frame organized in tree
;leaf = visible window. called live
;internal window (not visible)
;(also exist detached/deleted)
(selected-window)
;live windows
(window-list)


;minibuffer NOT in the tree, not a live window
;A minibuffer window (see Minibuffer Windows) is not part of its
;frame's window tree unless the frame is a minibuffer-only frame.

;minibuffer alongside window-tree
;((t (0 0 126 63) #<window 1 on take-off.el> #<window 22 on take-off.el>) #<window 2 on  *Minibuf-0*>)
(window-tree)
;
;(window-full-height-p (car (window-tree)))

(window-total-height)
(window-total-width nil)
(frame-width)

(window-body-height)
(window-body-width)

;include header, scroll, fringe, buffer,...
;28.23
(window-edges)

(window-edges)


(window-inside-edges)

;point = position in buffer
;there is a point for buffer and window
;they are equal when a window has the buffer

(window-point)
(window-start)
(window-end)

(buffer-substring (window-start) (window-end))
(buffer-substring-no-properties (window-start) (window-end))
(buffer-substring-no-properties  (point-min)  200)
;!! word wrap, left of window is no beginning of lines
(pos-visible-in-window-p (point) (selected-window) t)
(pos-visible-in-window-p t (selected-window) t)

(window-line-height)

(buffer-string)


;buffer point values
(point-min)
(point-max)

(buffer-size)
;?






;things to consider:
(track-mouse )
;21.7.13
;28.18
;28.19

;scroll bar 
;21.7.14

;text property 32.19

;popup menu

;popup dialogs
