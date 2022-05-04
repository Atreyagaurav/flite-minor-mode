;;; flite-minor-mode.el --- minor mode for flite TTS -*- lexical-binding: t -*-

;; Author: Gaurav Atreya <allmanpride@gmail.com>
;; Maintainer: Gaurav Atreya <allmanpride@gmail.com>
;; Version: 0.1
;; Package-Requires: ((cl-lib "0.5"))
;; Homepage: https://github.com/Atreyagaurav/flite-minor-mode
;; Keywords: festival,flite,tts,text-to-speech


;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; For detailed help visit github page:
;; https://github.com/Atreyagaurav/flite-minor-mode

;;; Code:
(require 'cl-lib)
(unless (fboundp 'make-overlay)
  (require 'overlay))

(defvar flite-executable "flite"
  "Executable to call for flite process.")

(defvar flite-args "-pw"
  "Arguments to pass for flite process.")

(defvar flite-reading-overlay-region (make-overlay 0 0)
  "overlay region.")

(defvar flite-reading-overlay-current (make-overlay 0 0)
  "overlay current.")

;; faces for highlighting
(defface flite--reading-region
  '((((class color) (background light))
     :background "lightblue")
    (((class color) (background dark))
     :background "steelblue4")
    (t
     :inverse-video t))
  "Face for displaying the whole region flite is reading."
  :group 'flite)

(defface flite--reading-current
  '((((class color) (background light))
     :background "springgreen")
    (((class color) (background dark))
     :background "chartreuse4")
    (t
     :inverse-video t))
  "Face for displaying current region it's reading."
  :group 'flite)

(defconst flite--overlay-priority 1001
  "Starting priority of visual-regexp overlays.")


(defun flite-overlay-region (beg end)
  (overlay-put flite-reading-overlay-region 'face 'flite--reading-region)
  (overlay-put flite-reading-overlay-region 'priority flite--overlay-priority)
  (if (and beg end)
      (move-overlay flite-reading-overlay-region beg end)
    flite-reading-overlay-region))

(defun flite-overlay-current (beg end)
  (overlay-put flite-reading-overlay-current 'face 'flite--reading-current)
  (overlay-put flite-reading-overlay-current 'priority (1+ flite--overlay-priority))
  (if (and beg end)
      (move-overlay flite-reading-overlay-current beg end)
    flite-reading-overlay-current))

(defun flite-clear-overlays ()
  (interactive)
  (delete-overlay flite-reading-overlay-current)
  (delete-overlay flite-reading-overlay-region))


(defun flite-read-string (string &optional beg end)
  "Read give string."
  (let ((overlay (flite-overlay-current beg end)))
    (redisplay)
    (shell-command (format "%s %s -t %s"
			   flite-executable
			   flite-args
			   (shell-quote-argument string)))
    (delete-overlay overlay)
    (message string)))


(defun flite-read-region-lines (beg end)
  "Read region line by line."
  (interactive "r")
  (save-excursion
    (let ((overlay (flite-overlay-region beg end)))
      (redisplay)
      (goto-char beg)
      (cl-loop
       do (let ((bol (max beg (point-at-bol)))
		(eol (min end (point-at-eol))))
	    (flite-read-string (buffer-substring-no-properties bol eol) bol eol)
	    (forward-line 1))
       until (> (point) end))
      (delete-overlay overlay))
    (message "Done.")))


(defun flite-read-last-kill-lines ()
  "Read last killed text line by line."
  (interactive)
  (let ((lines
	 (split-string
	  (substring-no-properties (car kill-ring)) "\n")))
    (cl-loop for line in lines
	     do (flite-read-string line))
    (message "Done.")))


(defun flite-read-region-words (beg end)
  "Read region word by word."
  (interactive "r")
  (let ((overlay (flite-overlay-region beg end)))
    (redisplay)
    (save-excursion
      (goto-char beg)
      (forward-word 1)
      (cl-loop
       do (let ((bow beg)
		(eow (min end (point))))
	    (flite-read-string (buffer-substring-no-properties bow eow) bow eow)
	    (setq beg eow)
	    (forward-word 1))
       until (> (point) end))
       (delete-overlay overlay)))
  (message "Done."))


(defun flite-read-words-from-point ()
  "Read word by word starting from current point."
  (interactive)
    (flite-read-region-words (point) (point-max)))

(defun flite-read-lines-from-point ()
  "Read line by line starting from current point."
  (interactive)
    (flite-read-region-lines (point) (point-max)))

(defun flite-resume-last-words ()
  "Read word by word starting from current point."
  (interactive)
  (let ((beg (overlay-start flite-reading-overlay-current))
	(end (overlay-end flite-reading-overlay-region)))
    (if (and beg end)
	(flite-read-region-words beg end)
      (message "Nothing to resume."))))

(defun flite-resume-last-lines ()
  "Read line by line starting from current point."
  (interactive)
  (let ((beg (overlay-start flite-reading-overlay-current))
	(end (overlay-end flite-reading-overlay-region)))
    (if (and beg end)
     (flite-read-region-lines beg end)
      (message "Nothing to resume."))))


(define-minor-mode flite-minor-mode
  "Minor mode for Flite TTS system.")

  ;; :keymap '(([menu-bar flite]
  ;; 	     (cons "Flite" (make-sparse-keymap)))
  ;; 	    ([menu-bar flite read-region]
  ;; 	     '("Read Region" . flite-read-region-lines)))

(provide 'flite-minor-mode)

;;; flite-minor-mode.el ends here
