#!/usr/bin/guile \
-s
!#
;; Written for guile
;;

(define BRDIP "192.168.0.255")
(define MACTB '((bebop.l "70:5A:B6:94:8F:59")
                (gamer.l "00:25:22:f4:0b:0e")
                (lore.l  "00:40:ca:6d:16:07")
                (nox.l   "00:40:63:D5:8B:65")
                (rpi.l   "B8:27:EB:0D:EB:01")))

(use-modules (rnrs bytevectors)
             (srfi srfi-1))

(define-syntax times
  (syntax-rules ()
                ((times count body ...)
                 (do ((i 1 (1+ i))) ((> i count))
                   (begin body ...)))))

(define (die msg)
  (map display (list "ERROR: " msg "!"))
  (newline)
  (exit 2))

(define (mac-get key)
  (let ((mac (assq key MACTB)))
    (if mac
      (cadr mac)
      (die (format #f "Host '~s' not found" key)))))

(define (payload-make mac)
  (u8-list->bytevector
    (append
      (make-list 6 255)
      (fold append '() (make-list 16 (fold-right
                                       (lambda (x rs)
                                         (cons (string->number x 16) rs))
                                       '() (string-split mac #\:)))))))

(define (payload-send payload)
  (let ((sock (socket PF_INET SOCK_DGRAM 0))
        (target (make-socket-address AF_INET (inet-pton AF_INET BRDIP) 9 MSG_PEEK)))
    (setsockopt sock SOL_SOCKET SO_BROADCAST 1)
    (times 3 (sendto sock payload target))))

(payload-send
  (payload-make
    (mac-get
      (string->symbol (cadr (command-line))))))
