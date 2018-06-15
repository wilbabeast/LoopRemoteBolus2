//
//  LoopSettings.swift
//  Loop
//
//  Copyright © 2017 LoopKit Authors. All rights reserved.
//

import LoopKit
import RileyLinkBLEKit


struct LoopSettings {
    var dosingEnabled = false

    let dynamicCarbAbsorptionEnabled = true

    var glucoseTargetRangeSchedule: GlucoseRangeSchedule?

    var maximumBasalRatePerHour: Double?

    var maximumBolus: Double?

    var suspendThreshold: GlucoseThreshold? = nil
    
    var bolusThreshold: BolusThreshold? = nil

    var retrospectiveCorrectionEnabled = true
    
      let absorptionTimeOverrun = 1.8
}


// MARK: - Static configuration
extension LoopSettings {
    static let idleListeningEnabledDefaults: RileyLinkDevice.IdleListeningState = .enabled(timeout: .minutes(4), channel: 0)
}


extension LoopSettings {
    var enabledEffects: PredictionInputEffect {
        var inputs = PredictionInputEffect.all
        if !retrospectiveCorrectionEnabled {
            inputs.remove(.retrospection)
        }
        return inputs
    }
}


extension LoopSettings: RawRepresentable {
    typealias RawValue = [String: Any]
    private static let version = 1

    init?(rawValue: RawValue) {
        guard
            let version = rawValue["version"] as? Int,
            version == LoopSettings.version
        else {
            return nil
        }

        if let dosingEnabled = rawValue["dosingEnabled"] as? Bool {
            self.dosingEnabled = dosingEnabled
        }

        if let rawValue = rawValue["glucoseTargetRangeSchedule"] as? GlucoseRangeSchedule.RawValue {
            self.glucoseTargetRangeSchedule = GlucoseRangeSchedule(rawValue: rawValue)
        }

        self.maximumBasalRatePerHour = rawValue["maximumBasalRatePerHour"] as? Double

        self.maximumBolus = rawValue["maximumBolus"] as? Double

        if let rawThreshold = rawValue["minimumBGGuard"] as? GlucoseThreshold.RawValue {
            self.suspendThreshold = GlucoseThreshold(rawValue: rawThreshold)
        }
        if let rawBolusThreshold = rawValue["minimumBolusGuard"] as? BolusThreshold.RawValue {
            self.bolusThreshold = BolusThreshold(rawValue: rawBolusThreshold)
        }
        if let retrospectiveCorrectionEnabled = rawValue["retrospectiveCorrectionEnabled"] as? Bool {
            self.retrospectiveCorrectionEnabled = retrospectiveCorrectionEnabled
        }
    }

    var rawValue: RawValue {
        var raw: RawValue = [
            "version": LoopSettings.version,
            "dosingEnabled": dosingEnabled,
            "retrospectiveCorrectionEnabled": retrospectiveCorrectionEnabled
        ]

        raw["glucoseTargetRangeSchedule"] = glucoseTargetRangeSchedule?.rawValue
        raw["maximumBasalRatePerHour"] = maximumBasalRatePerHour
        raw["maximumBolus"] = maximumBolus
        raw["minimumBGGuard"] = suspendThreshold?.rawValue
        raw["minimumBolusGuard"] = bolusThreshold?.rawValue

        return raw
    }
}
