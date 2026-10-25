--!strict
local SoundService = game:GetService("SoundService")

local AudioController = {}

local sounds: { [string]: Sound } = {}

-- Standard Roblox audio asset IDs or synthesized procedural sound pitches
local SOUND_CONFIGS = {
    wet_pop = { Pitch = 1.3, Volume = 0.5 },
    rattle = { Pitch = 1.5, Volume = 0.5 },
    pop = { Pitch = 1.6, Volume = 0.6 },
    hum = { Pitch = 0.9, Volume = 0.4 },
    unroll = { Pitch = 1.1, Volume = 0.5 },
    click = { Pitch = 1.4, Volume = 0.6 },
    vote_tap = { Pitch = 1.2, Volume = 0.6 },
    fanfare = { Pitch = 1.0, Volume = 0.7 },
}

function AudioController.init()
    local soundGroup = Instance.new("SoundGroup")
    soundGroup.Name = "StyleASnackSounds"
    soundGroup.Parent = SoundService

    for name, config in pairs(SOUND_CONFIGS) do
        local sound = Instance.new("Sound")
        sound.Name = name
        sound.SoundGroup = soundGroup
        sound.Volume = config.Volume
        sound.PlaybackSpeed = config.Pitch
        -- Built-in UI sound fallbacks
        sound.SoundId = "rbxasset://sounds/button.wav"
        sound.Parent = soundGroup
        sounds[name] = sound
    end
end

function AudioController.play(soundName: string)
    local sound = sounds[soundName]
    if sound then
        pcall(function()
            sound:Play()
        end)
    end
end

return AudioController
