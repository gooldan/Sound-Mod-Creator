

var db={
    "events":[
        {
            "name":"Event1",
            "name":"Event2",
            "name":"Event3",
            "name":"Event4",
            "name":"Event5",
        }
    ],
    "states":[
        {
            "name":"PostFxHitType",
            "accepts":[
                "Event1",
                "Event3",
                "Event5"
            ],
            "content":[
                "AP",
                "Bomb",
                "HE",
                "seaMine",
                "torpedo"
            ]
        },
        {
            "name":"HitRelation",
            "accepts":[
                "Event1",
                "Event5"
            ],
            "content":[
                "Ship",
                "Terrain",
                "Water"
            ]
        },
        {
            "name":"Autopilot",
            "accepts":[
                "Event1"
            ],
            "content":[
                "Checkpoint",
                "Bomb",
                "End",
                "Off",
                "On"
            ]
        }

    ]

}

function func() {

}
