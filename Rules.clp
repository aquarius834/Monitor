(defrule MAIN::Begin-Next-Cycle
	?f <- (cycle ?current-cycle)
	(exists (device (status on)))
=>
	(retract ?f)
	(assert (cycle (+ ?current-cycle 1)))
	(focus INPUT TRENDS WARNINGS)
)

(defrule MAIN::End-Cycles
	(not (device (status on)))
=>
	(printout t "ALL devices are off" crlf)
	(printout t "Halting monitoring system" crlf)
	(halt)
)

(defrule INPUT::Next-Cycle
	(cycle ?cycle)
	?f <- (local-cycle ~?cycle)
	(data-source ?source)
	(object (is-a DATA-SOURCE) (name ?source))
=>
	(send ?source next-cycle ?cycle)
	(retract ?f)
	(assert (local-cycle ?cycle))
)

(defrule INPUT::Get-Sensor-Value-From-DATA-SOURCE
	(cycle ?cycle)
	(local-cycle ?cycle)
	(data-source ?source)
	(object (is-a DATA-SOURCE) (name ?source))
	?s <- (sensor (name ?name) (raw-value none) (device ?device))
	(device (name ?device) (status on))
=>
	(bind ?raw-value (send ?source get-data ?name))
	(if (not (numberp ?raw-value))
		then
			(printout t "No data for sensor " ?name crlf)
			(printout t "Halting monitoring system" crlf)
			(halt)
		else
			(modify ?s (raw-value ?raw-value))
	)
)

(defrule TRENDS::Normal-State
	?s <- (sensor
				(raw-value ?raw-value&~none)
				(low-guard-line ?lgl)
				(high-guard-line ?hgl)
			)
	(test (and (> ?raw-value ?lgl) (< ?raw-value ?hgl)))
=>
	(modify ?s (state normal) (raw-value none))
)

(defrule TRENDS::High-Guard-Line-State
	?s <- (sensor
				(raw-value ?raw-value&~none)
				(high-guard-line ?hgl)
				(high-red-line ?hrl)
			)
	(test (and (>= ?raw-value ?hgl) (< ?raw-value ?hrl)))
=>
	(modify ?s (state high-guard-line) (raw-value none))
)

(defrule TRENDS::High-Red-Line-State
	?s <- (sensor
				(raw-value ?raw-value&~none)
				(high-red-line ?hrl)
			)
	(test (>= ?raw-value ?hrl))
=>
	(modify ?s (state high-red-line) (raw-value none))
)

(defrule TRENDS::Low-Guard-Line-State
	?s <- (sensor
				(raw-value ?raw-value&~none)
				(low-guard-line ?lgl)
				(low-red-line ?lrl)
			)
	(test (and (<= ?raw-value ?lgl) (> ?raw-value ?lrl)))
=>
	(modify ?s (state low-guard-line) (raw-value none))
)

(defrule TRENDS::Low-Red-Line-State
	?s <- (sensor
				(raw-value ?raw-value&~none)
				(low-red-line ?lrl)
			)
	(test (<= ?raw-value ?lrl))
=>
	(modify ?s (state low-red-line) (raw-value none))
)

(defrule TRENDS::State-Has-Not-Changed
	(cycle ?time)
	?trend <- (sensor-trend (name ?sensor) (state ?state) (end ?end-cycle&~?time))
	(sensor (name ?sensor) (state ?state) (raw-value none))
=>
	(modify ?trend (end ?time))
)

(defrule TRENDS::State-Has-Changed
	(cycle ?time)
	?trend <- (sensor-trend (name ?sensor) (state ?state) (end ?end-cycle&~?time))
	(sensor (name ?sensor) (state ?new-state&~?state) (raw-value none))
=>
	(modify ?trend (state ?new-state) (start ?time) (end ?time))
)

(defrule WARNINGS::Shutdown-In-Red-Region
	(cycle ?time)
	(sensor-trend (name ?sensor) (state ?state&high-red-line | low-red-line))
	(sensor (name ?sensor) (device ?device))
	?on <- (device (name ?device) (status on))
=>
	(printout t "Cycle " ?time " - ")
	(printout t "Sensor " ?sensor " in " ?state crlf)
	(printout t "   Shutting down device " ?device crlf)
	(modify ?on (status off))
)

(defrule WARNINGS::Shutdown-In-Guard-Region
	(cycle ?time)
	(sensor-trend
		(name ?sensor)
		(state ?state&high-guard-line | low-guard-line)
		(shutdown-duration ?length)
		(start ?start)
		(end ?end)
	)
	(test (>= (+ (- ?end ?start) 1) ?length))
	(sensor (name ?sensor) (device ?device))
	?on <- (device (name ?device) (status on))
=>
	(printout t "Cycle " ?time " - ")
	(printout t "Sensor " ?sensor " in " ?state crlf)
	(printout t " for " ?length " cycles " crlf)
	(printout t "   Shutting down device " ?device crlf)
	(modify ?on (status off))
)

(defrule WARNINGS::Sensor-In-Guard-Region
	(cycle ?time)
	(sensor-trend
		(name ?sensor)
		(state ?state&high-guard-line | low-guard-line)
		(shutdown-duration ?length)
		(start ?start)
		(end ?end)
	)
	(test (< (+ (- ?end ?start) 1) ?length))
=>
	(printout t "Cycle " ?time " - ")
	(printout t "Sensor " ?sensor " in " ?state crlf)
)





