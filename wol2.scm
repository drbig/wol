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

(use-modules (rnrs bytevectors) (srfi srfi-1))
(define *payload* (make-typed-array 'u8 255 102))

(define (payload-update mac)
  (let ((x 0))
    (map (lambda (e)
           (let loop ((y 0))
             (array-set! *payload* (string->number e 16) (+ x y 6))
             (if (< y 90) (loop (+ y 6))))
           (set! x (+ x 1)))
         (string-split mac #\:))) *payload*)

(let ((sock (socket PF_INET SOCK_DGRAM 0))
      (target (make-socket-address AF_INET (inet-pton AF_INET BRDIP) 9 MSG_PEEK)))
  (begin
    (setsockopt sock SOL_SOCKET SO_BROADCAST 1)
    (map (lambda (token)
           (let ((addr (assq-ref MACTB (string->symbol token))))
             (begin
               (set! addr (if addr (car addr) token))
               (unless
                 (false-if-exception
                   (map (lambda (x) (sendto sock (payload-update addr) target)) '(1 2 3)))
                 (display (string-append token ": parse error!\n"))))))
         (cdr (command-line)))))
