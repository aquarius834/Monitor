(deffacts MAIN::device-information
	(device (name D1) (status on))
	(device (name D2) (status on))
	(device (name D3) (status on))
	(device (name D4) (status on))
)

(deffacts MAIN::sensor-information
	(sensor (name S1)
			(device D1)
			(low-red-line 60)
			(low-guard-line 70)
			(high-guard-line 120)
			(high-red-line 130)
	)
	(sensor (name S2)
			(device D1)
			(low-red-line 20)
			(low-guard-line 40)
			(high-guard-line 160)
			(high-red-line 180)
	)
	(sensor (name S3)
			(device D2)
			(low-red-line 60)
			(low-guard-line 70)
			(high-guard-line 120)
			(high-red-line 130)
	)
	(sensor (name S4)
			(device D3)
			(low-red-line 60)
			(low-guard-line 70)
			(high-guard-line 120)
			(high-red-line 130)
	)
	(sensor (name S5)
			(device D4)
			(low-red-line 65)
			(low-guard-line 70)
			(high-guard-line 120)
			(high-red-line 125)
	)
	(sensor (name S6)
			(device D4)
			(low-red-line 110)
			(low-guard-line 115)
			(high-guard-line 125)
			(high-red-line 130)
	)
)

(deffacts MAIN::cycle-start
	(data-source [user])
	(cycle 0)
)

(deffacts MAIN::local-cycle
	(local-cycle 0)
)

(definstances INPUT::data-source
	([user] of DATA-SOURCE)
)

(definstances INPUT::instance-data-source
	([instance] of INSTANCE-DATA-SOURCE)
)

(definstances INPUT::sensor-instance-data-values
	([S1-DATA-SOURCE] of SENSOR-DATA
		(data 100 100 110 110 115 120)
	)
	([S2-DATA-SOURCE] of SENSOR-DATA
		(data 110 120 125 130 130 135)
	)
	([S3-DATA-SOURCE] of SENSOR-DATA
		(data 100 120 125 130 130 125)
	)
	([S4-DATA-SOURCE] of SENSOR-DATA
		(data 120 120 120 125 130 135)
	)
	([S5-DATA-SOURCE] of SENSOR-DATA
		(data 110 120 125 130 135 135)
	)
	([S6-DATA-SOURCE] of SENSOR-DATA
		(data 115 120 125 135 130 135)
	)
)

(definstances INPUT::file-data-source
	([file] of FILE-DATA-SOURCE)
)

(deffacts MAIN::start-trends
	(sensor-trend (name S1) (shutdown-duration 3))
	(sensor-trend (name S2) (shutdown-duration 5))
	(sensor-trend (name S3) (shutdown-duration 4))
	(sensor-trend (name S4) (shutdown-duration 4))
	(sensor-trend (name S5) (shutdown-duration 4))
	(sensor-trend (name S6) (shutdown-duration 2))
)