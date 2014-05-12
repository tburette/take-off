(require 'cl)
(require 'json)

(defun take-off-static-files (request)
      (with-slots (process headers) request
	(let ((serve-path (expand-file-name (file-relative-name "../front")))
	      (path (substring (cdr (assoc :GET headers)) 1)))
	  (message ">%s" serve-path)
	  (if (ws-in-directory-p serve-path path)
	      (if (file-directory-p path)
		  (ws-send-directory-list process
		    (expand-file-name path serve-path) "^[^\.]")
		
		(ws-send-file process (expand-file-name path serve-path)))
	    (ws-send-404 process)))
      ))

(defun take-off-web-socket-receive (proc string)
	  (message ">%s" "ws receive")
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
	       (puthash :text
		 ;window-end is wrong
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
(print"\n")

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

(pos-visible-in-window-p 6330
(selected-window) t)

(pos-visible-in-window-p 6392 (selected-window) t);48, 0

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



