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

(defvar flite-executable "flite"
  "Executable to call for flite process.")

(defun flite-say-string (string)
  "Speak give string."
  (shell-command (format "%s -t \"%s\""
			 flite-executable
			 string)))

(defun flite-say-region (beg end)
  "Speak region."
  (interactive "r")
  (let ((lines
	 (split-string
	  (buffer-substring-no-properties beg end))))
    (cl-loop for line in lines
	     do (flite-say-string line))))



(define-key-after
  global-map
  [menu-bar flite]
  (cons "Flite" (make-sparse-keymap))
  'tools )

;; Creating a menu item, under the menu by the id “[menu-bar flite]”
(define-key
  global-map
  [menu-bar flite say-region]
  '("Read Region" . flite-say-region))


(define-minor-mode flite-minor-mode
  "Minor mode for Flite TTS system."
  :lighter " fl")

(provide 'flite-minor-mode)

;;; flite-minor-mode.el ends here
