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

(defun take-off-web-socket-receive (proc string)
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

(defun take-off-set-window-pos (window hashtable)
  (mapcar*;zip
   (lambda (key val)
     (puthash key val hashtable)
     )
  '(:left :top :right :bottom)
  (window-inside-edges window))
  hashtable
)

(window-inside-edges)
(pos-visible-in-window-p (window-point) nil t)

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
	     hash
	     )))
       (window-list))
      windows-data)
;    windows-data)
    (json-encode windows-data))
)

(take-off-visible-data)

;+mid text
;os -- fro
;returns entire line. don't know some is clipped (know from size  but don;t know which part)
{\"text\":\"       {\\t\\t\\t\\t\\t\\\\\\n\\t --(POS).charpos;\\t\\t\\t\\\\\\n         if (MULTIBYTE_P)\\t\\t\\t\\\\\\n\\t   DEC_POS ((POS).bytepos);\\t\\t\\\\\\n\\t else\\t\\t\\t\\t\\t\\\\\\n\\t   --(POS).bytepos;\\t\\t\\t\\\\\\n       }\\t\\t\\t\\t\\t\\\\\\n     while (0)\\n\\n\\/* Set text position POS from marker MARKER.  *\\/\\n\\n#define SET_TEXT_POS_FROM_MARKER(POS, MARKER)\\t\\t\\\\\\n     (CHARPOS (POS) = marker_position ((MARKER)),\\t\\\\\\n      BYTEPOS (POS) = marker_byte_position ((MARKER)))\\n\\n\\/* Set marker MARKER from text position POS.  *\\/\\n\\n#define SET_MARKER_FROM_TEXT_POS(MARKER, POS) \\\\\\n     set_marker_both ((MARKER), Qnil, CHARPOS ((POS)), BYTEPOS ((POS)))\\n\\n\\/* Value is non-zero if character and byte positions of POS1 and POS2\\n   are equal.  *\\/\\n\\n#define TEXT_POS_EQUAL_P(POS1, POS2)\\t\\t\\\\\\n     ((POS1).charpos == (POS2).charpos\\t\\t\\\\\\n      && (POS1).bytepos == (POS2).bytepos)\\n\\n\\/* When rendering glyphs, redisplay scans string or buffer text,\\n   overlay strings in that text, and does display table or control\\n   character translations.  The following structure captures a\\n\", \"bottom\":60, \"right\":34, \"top\":30, \"left\":17}], \"height\":62, \"width\":34}"



+court line wrap
;know wrap indirectly : line number vs \n. can reconstructu because have size
{\"text\":\"       {\\t\\t\\t\\t\\t\\\\\\n\\t --(POS).charpos;\\t\\t\\t\\\\\\n         if (MULTIBYTE_P)\\t\\t\\t\\\\\\n\\t   DEC_POS ((POS).bytepos);\\t\\t\\\\\\n\\t else\\t\\t\\t\\t\\t\\\\\\n\\t   --(POS).bytepos;\\t\\t\\t\\\\\\n       }\\t\\t\\t\\t\\t\\\\\\n     while (0)\\n\\n\\/* Set text position POS from marker MARKER.  *\\/\\n\\n#define SET_TEXT_POS_FROM_MARKER(POS, MARKER)\\t\\t\\\\\\n     (CHARPOS (POS) = marker_position ((MARKER)),\\t\\\\\\n      BYTEPOS (POS) = marker_byte_position ((MARKER)))\\n\\n\\/* Set marker MARKER from text position POS.  *\\/\\n\\n#define SET_MARKER_FROM_TEXT_POS(MARKER, POS) \\\\\\n     set_marker_both ((MARKER), Qnil, CHARPOS ((POS)), BYTEPOS ((POS)))\\n\\n\\/* Value is non-zero if character and byte positions of POS1 and POS2\\n   are equal.  *\\/\\n\\n#define TEXT_POS_EQUAL_P(POS1, POS2)\\t\\t\\\\\\n     ((POS1).charpos == (POS2).charpos\\t\\t\\\\\\n      && (POS1).bytepos == (POS2).bytepos)\\n\\n\\/* When rendering glyphs, redisplay scans string or buffer text,\\n\", \"bottom\":60, \"right\":134, \"top\":30, \"left\":67}], \"height\":62, \"width\":134}"


+large no line wrap
;ok
{\"text\":\"       {\\t\\t\\t\\t\\t\\\\qwn\\t --(POS).charpos;\\t\\t\\t\\\\\\n         if (MULTIBYTE_P)\\t\\t\\t\\\\\\n\\t   DEC_POS ((POS).bytepos);\\t\\t\\\\\\n\\t else\\t\\t\\t\\t\\t\\\\\\n\\t   --(POS).bytepos;\\t\\t\\t\\\\\\n       }\\t\\t\\t\\t\\t\\\\\\n     while (0)\\n\\n\\/* Set text position POS from marker MARKER.  *\\/\\n\\n#define SET_TEXT_POS_FROM_MARKER(POS, MARKER)\\t\\t\\\\\\n     (CHARPOS (POS) = marker_position ((MARKER)),\\t\\\\\\n      BYTEPOS (POS) = marker_byte_position ((MARKER)))\\n\\n\\/* Set marker MARKER from text position POS.  *\\/\\n\\n#define SET_MARKER_FROM_TEXT_POS(MARKER, POS) \\\\\\n     set_marker_both ((MARKER), Qnil, CHARPOS ((POS)), BYTEPOS ((POS)))\\n\\n\\/* Value is non-zero if character and byte positions of POS1 and POS2\\n   are equal.  *\\/\\n\\n#define TEXT_POS_EQUAL_P(POS1, POS2)\\t\\t\\\\\\n     ((POS1).charpos == (POS2).charpos\\t\\t\\\\\\n      && (POS1).bytepos == (POS2).bytepos)\\n\\n\\/* When rendering glyphs, redisplay scans string or buffer text,\\n   overlay strings in that text, and does di splay table or control\\n   character translations.  The following structure captures a\\n\", \"bottom\":60, \"right\":149, \"top\":30, \"left\":74}], \"height\":62, \"width\":149}
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  (point) 
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab (point)

;(point)
(pos-visible-in-window-p 6126 (selected-window) t)

(pos-visible-in-window-p (window-point)(selected-window) t)



;pixel or character
;word wrap : start back at zero 
;            if width x.
;            x-2 = last of line
;            x-1 = \
;            x   = 0 on new line
;hscroll : = (window-width) - 1
;            can be negative
;
;filling?
window-end

(window-display-table)

(current-window-configuration)

(window-width)
(window-body-width)
(window-edges)
12345678901234567890123456789012345678901234567890

(window-hscroll)


(print line-prefix)


(0 1)

(0 3)



