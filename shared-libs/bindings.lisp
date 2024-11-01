
(in-package #:iv-debugger)

(cffi:defcfun ("wifexited" wifexited) :int
  (status :int))

(cffi:defcfun ("wexitstatus" wexitstatus) :int
  (status :int))

(cffi:defcfun ("wifsignaled" wifsignaled) :int
  (status :int))

(cffi:defcfun ("wtermsig" wtermsig) :int
  (status :int))

(cffi:defcfun ("wcoredump" wcoredump) :int
  (status :int))

(cffi:defcfun ("wifstopped" wifstopped) :int
  (status :int))

(cffi:defcfun ("wstopsig" wstopsig) :int
  (status :int))

(cffi:defcfun ("wifcontinued" wifcontinued) :int
  (status :int))
