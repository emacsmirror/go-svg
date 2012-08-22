;;; xml-gen.el --- A DSL for generating XML.

;; Copyright (C) 2012 William Stevenson

;; Author: William Stevenson <yhvh2000@gmail.com>
;; Version: 0.4

;; This file is not currently part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program ; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:
;; depends on xmlgen https://github.com/philjackson/xmlgen

(defgroup go-svg nil
  "Top level for go-svg customization.")

(defcustom go-program "/usr/bin/gnugo"
  "String containing Go program name."
  :type '(string)
  :group 'go-svg)

(defcustom go-program-args "--mode gtp"
  "String containing Go program command line arguments."
  :type '(string)
  :group 'go-svg)

(defvar go-boardsize 19)
(defvar go-img-size 500)
(defvar go-process-buffer "*gnugo*" ) ;; make local?
(defvar go-letter-map)

(defun go-process ()
  "Starts the go gtp process"
  (start-process "gnugo" "*gnugo*" "gnugo" "--mode" "gtp"))

(defun go-boardsize-set (size)
  "Set boardsize to SIZE and clear the board"
  (process-send-string go-process-buffer "boardsize 19\n"))

(defun go-play-stone (color pos)
  "Plays a stone of COLOR at position POS"
  (process-send-string go-process-buffer (concat "play " color " " pos "\n")))

(defun go-genmove (color)
  "Generate and play the supposedly best move for COLOR."
  (process-send-string go-process-buffer (concat "genmove " color "\n")))

(defun go-list-stones (color)
  "Returns a list of positions for COLOR"
  (process-send-string go-process-buffer (concat "list_stones " color " \n")))

(defun go-move-to-string (move)
  "Converts MOVE to string, `(1 5) will convert to `A5' ")

(defun go-string-to-move (string)
  "Converts string STRING to list, `A5' will convert to `(1 5)")

(defun go-stone-alist ()
  "Returns a list of all stones on board in the form
'((black 5 5) (white 6 3) (black 7 4))"
  '((black 0 0) (white 18 0) (black 0 18) (white 18 18)))

(defun go-stones (stones-alist)
  "Returns a list of circle S-expressions for splicing into svg."
  (mapcar
   (lambda (el)
     `(circle :cx ,(number-to-string (+ 2.5 (* 5 (car (cdr (cdr el))))))
	      :cy ,(number-to-string (+ 2.5 (* 5 (car (cdr el)))))
	      :r "2.4"
	      :fill ,(concat "url(#" (if (eq 'black (car el)) "rg" "wh") ")")))
   stones-alist))

(defun go-img-string ()
  "Returns a svg string for game image"
  (xmlgen
   `(svg :xmlns "http://www.w3.org/2000/svg"
	 :width ,(number-to-string go-img-size)
	 :height ,(number-to-string go-img-size)
	 :encoding "UTF-8" :viewBox "0 0 96 96"
	 (rect :width "114" :height "114" :fill "#DCB35C")
	 (path :stroke "#000" :stroke-width ".2" :fill "none"
	       :d "M2.9,93h90.2m-.2-5H3m0-5h90m0-5H3m0-5h90m0
-5H3m0-5h90m0-5H3m0-5h90m0-5H3m0-5h90m0-5H3m0-5h90m0-5H3m0-5h90m0
-5H3m0-5h90m0-5H3m-.1-5h90.2M3,3V93m5,0V3m5,0V93m5,0V3m5,0V93m5,
0V3m5,0V93m5,0V3m5,0V93m5,0V3m5,0V93m5,0V3m5,0V93m5,0V3m5,0V93m5,
0V3m5,0V93m5,0V3m5,0V93m5,0V3")
	 (path :stroke "#000" :stroke-width "2" :stroke-linecap "round"
	       :d "M18,78l0,0m30,0l0,0m30,0l0,0m0-30l0,0m-30,0l0,
0m-30,0l0,0m0-30l0,0m30,0l0,0m30,0l0,0")
	 (defs
	   (radialGradient :id "rg" :cx ".3" :cy ".3" :r ".8"
			   (stop :offset "0" :stop-color "#777")
			   (stop :offset ".3" :stop-color "#222")
			   (stop :offset "1" :stop-color "#000"))
	   (radialGradient :id "wh" :cx ".3" :cy ".3" :r ".8"
			   (stop :offset "0" :stop-color "#FEE")
			   (stop :offset ".3" :stop-color "#DDD")
			   (stop :offset "1" :stop-color "#FFF")))
	 ,@(go-stones (go-stone-alist)))))

(defun go-board-insert ()
  "Insert go board svg image at cursor pos"
  (insert-image
   (create-image (go-img-string) 'svg t
		 :map '(((circle . ((100 . 100) . 20))
			 area1
			 (pointer hand))))))
 
