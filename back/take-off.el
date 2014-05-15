(require 'cl)
(require 'json)

(defvar take-off-docroot (expand-file-name default-directory))

(defun take-off-static-files (request)
      (with-slots (process headers) request
	(let ((serve-path (expand-file-name (concat take-off-docroot "../front")))
	      (path (substring (cdr (assoc :GET headers)) 1)))
	  (if (ws-in-directory-p serve-path path)
	      (if (file-directory-p path)
		  (ws-send-directory-list process
		    (expand-file-name path serve-path) "^[^\.]")
		
		(ws-send-file process (expand-file-name path serve-path)))
	    (ws-send-404 process)))
      ))

(defun take-off-set-window-pos (window hashtable)
  (mapcar*;zip
   (lambda (key val)
     (puthash key val hashtable)
     )
  '(:left :top :right :bottom)
  (window-inside-edges window))
  hashtable
)

(defun take-off-set-point-pos (window hashtable)
  (if (eq window (selected-window))
   (let* ((pointhash (make-hash-table))
	  (inside-edges (window-inside-edges))
	  (left (car inside-edges))
	  (top (cadr inside-edges))
	  ;position of point relative to the window
	  (pos-point-relative (pos-visible-in-window-p (window-point window) window t))
	  ;compute x y of point in abolute (relative to frame)
	  (x-point (+ left (car pos-point-relative)))
	  (y-point (+ top (cadr pos-point-relative)))
	  )
     (puthash
      :point
      pointhash
      hashtable)

     (puthash :x (car pos-point-relative) pointhash)
     (puthash :y (cadr pos-point-relative) pointhash)

  )))

;json encode : hashtable become js object
(defun take-off-visible-data ()
  (let ((windows-data (make-hash-table)))
    (puthash :width (frame-width) windows-data)
    (puthash :height (frame-height) windows-data)
    (puthash :windows
      (mapcar
       (lambda (window)
	 (with-current-buffer (window-buffer window)
  	   (let ((hash (make-hash-table)))
	     (take-off-set-window-pos window hash)
	     (take-off-set-point-pos window hash)
	     (puthash :tabWidth
		      tab-width
		      hash)
	     (puthash :text
		 ;TODO window-end can be wrong
		 ;https://github.com/rolandwalker/window-end-visible
	       (buffer-substring-no-properties 
		(window-start window) 
		(window-end window))
	       hash)
	     (puthash :modeLine
	       (message (format-mode-line mode-line-format))
	       hash)
	     hash
	     )))
       (window-list))
      windows-data)
    (json-encode windows-data))
)

(defun take-off-web-socket-receive (proc string)
  (execute-kbd-macro (kbd string))
  (process-send-string proc
    (ws-web-socket-frame (take-off-visible-data) )))
	   
(defun take-off-web-socket-connect (request)
  (with-slots (process headers) request
    (if (ws-web-socket-connect 
	 request
	 'take-off-web-socket-receive)
	(prog1 
	  :keep-alive;prevent closing the connection immediatly after request
	  (setq take-off-connection))
        (ws-response-header process 501 '("Content-Type" . "text/html"))
	(ws-send process "Unable to create socket"))))

(defun take-off-is-socket-request (request)
  (string-prefix-p "/socket" (cdr (assoc :GET (oref request headers)))))

(ws-start
 '(
   (take-off-is-socket-request .
    take-off-web-socket-connect)
   ((:GET . ".*") . 
    take-off-static-files)
   ((lambda (request) t).
    (lambda (request)
      (with-slots (process headers) request
	(ws-response-header process 200 '("Content-Type" . "text/plain"))
	(process-send-string process "Default handler\n")))
    )
   )

 8000)

(ws-stop-all)
