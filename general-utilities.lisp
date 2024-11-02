
(in-package #:iv-debugger)

(defmacro error-format (fmt &rest args)
  `(error (format nil ,fmt ,@args)))

(defmacro force-format (stream fmt &rest args)
  `(progn
     (format ,stream ,fmt ,@args)
     (force-output)))

(defmacro force-print (fmt)
  `(progn
     (print ,fmt)
     (force-output)))

(defmacro println (fmt)
  `(progn
     (print ,fmt)
     (terpri)
     (force-output)))
