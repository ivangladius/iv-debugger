
(in-package #:iv-debugger)

(defparameter *instruction-map* (make-hash-table :test #'equal)
  "hashmap from instruction pointer (u64) to capstone instruction object or objects
   on this capstone instruction object we can use our instruction-* functions
   to obtain info")

(defparameter *capstone-engine*
  (make-instance 'capstone::capstone-engine :architecture :x86 :mode :64))

(defun instruction-add (ip bytes instruction-map)
  (let ((capstone-instruction-object (instruction-disasm :string bytes)))
    (setf (gethash ip instruction-map) capstone-instruction-object)))

(defun instruction-from-ip (ip instruction-map)
  (gethash ip instruction-map))

(defun instruction-disasm (&key bytes string)
  (let ((data (if string
		     (bit-smasher:hex->octets string)
		     bytes)))
      (capstone:disasm *capstone-engine* data)))

(defun instruction-mnemonics (capstone-instruction-vector)
  (let ((mnemonics '()))
    (dotimes (i (length capstone-instruction-vector))
      (push (instruction-mnemonic (aref capstone-instruction-vector i)) mnemonics))
    (nreverse mnemonics)))

(defun instruction-mnemonic (capstone-instruction-object)
  (capstone:mnemonic capstone-instruction-object))

(defun instruction-address (capstone-instruction-object)
  (capstone:address capstone-instruction-object))

(defun instruction-operands (capstone-instruction-object)
  (capstone:operands capstone-instruction-object))



