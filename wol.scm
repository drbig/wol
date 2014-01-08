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

(define (payload-parse mac)
  (fold-right
    (lambda (x rs) (cons (string->number x 16) rs))
    '() (string-split mac #\:)))

(define (payload-make mac)
  (u8-list->bytevector
    (append
      (make-list 6 255)
      (fold append '() (make-list 16 (payload-parse mac))))))

(let ((sock (socket PF_INET SOCK_DGRAM 0))
      (target (make-socket-address AF_INET (inet-pton AF_INET BRDIP) 9 MSG_PEEK)))
  (begin
    (setsockopt sock SOL_SOCKET SO_BROADCAST 1)
    (map (lambda (token)
           (let ((addr (assq-ref MACTB (string->symbol token))))
             (begin
               (if addr (set! addr (car addr)) (set! addr token))
               (unless
                 (false-if-exception
                   (map (lambda (x) (sendto sock (payload-make addr) target)) '(1 2 3)))
                 (display (string-append token ": parse error!\n"))))))
         (cdr (command-line)))))
