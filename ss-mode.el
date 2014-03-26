;;; ss-mode -- Spreadsheet Mode -- Tabular interface to Calc
;; Copyright (C) 2014 -- Use at 'yer own risk  -- NO WARRANTY!
;; Author: sam fiechter sam.fiechter(at)gmail
;; Version: 0.000000000000001
;; Created: 2014-03-24
;; Keywords: calc, tabular 


;;;Code

;; ;;;;;;;;;;;;; variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defvar ss-mode-empty-name "*Sams Spreadsheet Mode*")
(defvar ss-mode-column-widths (list ))
(defvar ss-mode-data [nil])
;; ;;;;;;;;;;;;; keymaps ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar ss-mode-map  (make-sparse-keymap 'ss-mode-map))

(define-key ss-mode-map "n"                'ss-start-game)
(define-key ss-mode-map "q"                'ss-end-game)

(define-key ss-mode-map [left]        'ss-move-left)
(define-key ss-mode-map [right]        'ss-move-right)
(define-key ss-mode-map [up]                'ss-move-up)
(define-key ss-mode-map [down]        'ss-move-down)


(defvar ss-null-map
  (make-sparse-keymap 'ss-null-map))
(define-key ss-null-map "n"                'ss-start-game)

;; ;;;;;;;;;;;;; functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SAM's SES MACROS



(defun ss-import-csv (filename)
  "Read a CSV file into ss-mode"
  (interactive "f")
  (find-file (concat filename ".ses"))
  (setq ss-mode-data [ ])
  (with-temp-buffer
   (insert-file-contents filename)
     (beginning-of-buffer)
     (while (not (eobp))
       (let ((x 0) (cell "") (row [])
	     (line (thing-at-point 'line)))
	 (dolist (cell (split-string line ","))
	   (if (and (char-equal "\"" (substring cell 0 0))
		    (char-equal "\"" (substring cell -1 -1)))
	       (setq cell (substring cell 1 -1)) nil )
	   (setq row (vconcat row '((formula . cell)) ))
	  )
	 (setq ss-mode-data (vconcat ss-mode-data row))
	 (with-current-buffer (ses-goto-print (x+1) 0))
	 (next-line) 
	 ))) )


(define-derived-mode ss-mode tabulated-list-mode ss-mode-empty-name
  "ss game mode
  Keybindings:
  \\{ss-mode-map} "
  (use-local-map ss-mode-map)
  ;; (unless (featurep 'emacs)
  ;;   (setq mode-popup-menu
  ;;         '("ss Commands"
  ;;           ["Start new game"        ss-start-game]
  ;;           ["End game"                ss-end-game
  ;;            (ss-active-p)]
  ;;           ))
  (setq tabulated-list-format [("" 4 t)]) ;; 0th row is for numbers
  (let ((a 0) (w 0))
    (dotimes (a 48)
      (setq w (elt ss-mode-column-widths a))     
      (setq tabulated-list-format (vconcat tabulated-list-format [ (list (char-to-string (+ ?A a)) (if (w) w 12) t)])) ) )
  (setq tabulated-list-padding 0)
  (tabulated-list-init-header) )

(defun ss-draw ()
  (interactive)
  (ss-listing-command)
  (tabulated-list-print t))

(defun ss-listing-command ()
  (interactive)
  ;;  (ss-mode)
  (let ((tbl (list) )
        (i 0) (j 0) (k 1) (ir 0)
        (tline [1 2 3 4])  (c " "))
    (dotimes (i 16)
      (setq ir (aref ss-board i))
      (if (= 0 ir)
          (setq c " ")
	(let ((color (ss-color ir)))
        (setq c (propertize (number-to-string ir) 'font-lock-face  color )) ))
      (aset tline j c)
      (if (= 3 j)
          (progn
            (add-to-list 'tbl (list  k (copy-sequence tline) ) 1 (lambda (a b) nil))
            (setq k (+ 1 k))
            (setq j 0)
            )
        (setq j (+ 1 j)) ))
    (setq tabulated-list-entries tbl) ))

;;;###autoload
(defun ss-mode ()
  "Open SS mode
     ss-mode keybindings:
     \\<ss-mode-map>
\\[ss-start-game]        Start a new game
\\[ss-end-game]        Terminate the current game
\\[ss-move-left]        Moves the board to the left
\\[ss-move-right]        Moves the board to the right
\\[ss-move-up]        Moves the board to the up
\\[ss-move-down]        Moves the board to the down
"
  (interactive)
  (pop-to-buffer ss-mode-empty-name nil)
  (ss-mode)
  (ss-start-game))


(provide 'ss-mode)

;;; ss-mode.el ends here
