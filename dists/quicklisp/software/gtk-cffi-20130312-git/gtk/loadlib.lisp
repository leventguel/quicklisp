;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-
;;;
;;; loadlib.lisp --- loading C library
;;;
;;; Copyright (C) 2007, Roman Klochkov <kalimehtar@mail.ru>
;;;

(in-package :gtk-cffi)

;; ;; Added possibility of using list of enums as sum 
;; (defmethod cffi::translate-type-to-foreign (value (type cffi::foreign-enum))
;;   (cond
;;    ((keywordp value) (cffi::%foreign-enum-value type value))
;;    ((listp value)
;;     (apply '+ (mapcar
;;                (lambda (x) (cffi::translate-type-to-foreign x type))  value)))
;;    (t value)))


(eval-when (:compile-toplevel :load-toplevel)
  (unless (find :gtk *features*)
    (push :gtk *features*)
    (define-foreign-library :gtk
      (:unix (:or "libgtk-3.so.0" "libgtk-3.so"))
      (:windows "libgtk-win32-3-0.dll"))
    
    (use-foreign-library :gtk)))

(eval-when (:compile-toplevel)
  (defcfun ("gtk_init" %gtk-init) :void (argc :pointer) (argv :pointer))

  #+sbcl (sb-ext::set-floating-point-modes :traps nil)
  (with-foreign-objects ((argc :int) (argv :pointer))
    (setf (mem-ref argc :int) 0
          (mem-ref argv :pointer) (foreign-alloc :string 
                                                 :initial-element "program"))
    (%gtk-init argc argv))
  (defcfun gtk-get-major-version :uint)
  (defcfun gtk-get-minor-version :uint)
  (when (and (>= (gtk-get-major-version) 3) (>= (gtk-get-minor-version) 2))
    (push :gtk3.2 *features*))
  (when (and (>= (gtk-get-major-version) 3) (>= (gtk-get-minor-version) 4))
    (push :gtk3.4 *features*)))

