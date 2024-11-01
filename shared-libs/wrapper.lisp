

;; wrapper functions over the bindings
;; status is of type (cffi:foreign-alloc :int) to pass in
;; with
;;      pid_t wait(int *_Nullable wstatus);
;;      pid_t waitpid(pid_t pid, int *_Nullable wstatus, int options);
;;
;;
