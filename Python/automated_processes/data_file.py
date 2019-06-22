##
#
#  KEYS AND PASSWORDS FOR API ACCOUNTS
#  ###  ONLY USE { OR } AROUND KEYS WHEN USING A FOR LOOP!!! ###
#  ###  LOOK AT SITE ADDITIONS AND DOMAIN FOR EXAMPLE ###
#
#  OLD AOL FEE REMOVED 2018-01-25: DC_.56 ADSYM_.56 TM_.64 ADTRANS_67
#
##


platforms = {
    "dna" : {
        "id" : "1",
        "fee" : "1",
        "market_id": {
            "public": "1",
            "private": "2"
            },
        "access": {
            "id": "daf5fa63-56c4-4279-842e-639c9af75750",
            "secret": "C5eBl8aErmCMO2+U85LGpw"
            },
        },
    "dc" : {
        "id" : "2",
        "fee" : "1",
        "market_id": {
            "public": "25",
            "private": "26"
            },
        "access": {
            "id": "0e30062d-6746-4a9b-882a-3f61185479c7",
            "secret": "9O7SnFq/yDbNK+4M2bkSqg"
            },
        },
    "adsym" : {
        "id" : "4",
        "fee" : "1",
        "market_id": {
            "public": "32",
            "private": "30"
            },
        "access": {
            "id": "25e5de37-aa8d-4d93-b407-29bc42b86044", 
            "secret": "stEVHyPObmxCTeI6mTMKuA"
            },
        },
    "tm" : {
        "id" : "5",
        "fee" : "1",
        "market_id": {
            "public": "36",
            "private": "37"
            },
        "access": {
            "id": "9fadb507-01e9-4a2a-b9c5-c9d65d93396e",
            "secret": "y0QxY3DC7vbczeW7nBOsZg"
            },
        },
    "adtrans" : {
        "id": "6",
        "fee" : "1",
        "market_id": {
            "public": "34",
            "private": "35"
            },
        "access": {
            "id": "629065c0-a967-473b-b62e-cf4353d9f5c7",
            "secret": "3GLSSYb1BxWdlN3Iu8/p7A"
            },
        },
    "springs": {
        "id": "7",
        "market_id": {
            "public": "",
            "private": "39"
            },
        "access": {
            "id": "bill_api@epiphanyai.com",
            "secret": "Dn2u2gnSjRZf"
            }
        
    }
}

fees = {
    "aol_cost" : ".20",
    "aol_platform" : ".24"
    }

report_book = {
    "Domain_v2": {
        "dna" : {"119546"},
        "dc" : {"143520"},
        "adsym" : {"161179"},
        "tm" : {"169377"},
        "adtrans" : {"169707"}
        },

    "InventorySources_v2" : {
        "dna" :  ["189983", "189984", "189985", "189986", "189987", "189989"],
        "dc" : ["190586", "190587", "190588", "190589", "190590", "190591"],
        "adsym" : ["190592", "190593", "190594", "190595", "190596", "190597"],
        "tm" : ["190598", "190599", "190601", "190602", "190603", "190604"],
        "adtrans" : ["190605", "190606", "190607", "109608", "190609", "190610"]
        },

    "inventoryreport" : {
        "dna": {"193231"},
        "dc" : {"143128"},
        "adsym" : {"161172"},
        "tm" : {"169370"},
        "adtrans" : {"169697"}
        },

    "inventorysources" : {
        "dna" : {"193229"},
        "dc" : {"145230"},
        "adsym" : {"161173"},
        "tm" : {"169500"},
        "adtrans" : {"169696"}
        },

    "market_private" : {
        "dna" : {"193232"},
        "dc" : {"143154"},
        "adsym" : {"161184"},
        "tm" : {"169371"},
        "adtrans" : {"169699"}
        },

    "market_public" : {
        "dna" : {"193233"},
        "dc" : {"143155"},
        "adsym" : {"210668"},
        "tm" : {"210670"},
        "adtrans" : {"210669"}
        },

    "site_additions" : {
        "adsym" : ["212234"],
        "adtrans" : ["212237"],
        "dc" : ["212236"],
        "tm" : ["212235"]
        },

    "market_today" : {
        "dna" : {"212012"},
        "dc" : {"212034"},
        "adsym" : {"212038"},
        "tm" : {"212044"},
        "adtrans" : {"212041"}
        },

    "core_last60" : {
        "dna" : {"194308"},
        "dc" : {"150659"},
        "adsym" : {"161186"},
        "tm" : {"169832"},
        "adtrans" : {"169869"}
        },

    "market_last60" : {
        "dna" : {"212428"},
        "dc" : {"150662"},
        "adsym" : {"161195"},
        "tm" : {"169839"},
        "adtrans" : {"169875"}
        },

    "market_yesterday" : {
        "dna" : {"143991"},
        "dc" : {"143986"},
        "adsym" : {"161197"},
        "tm" : {"169841"},
        "adtrans" : {"169877"}
        },

    "core_yesterday" : {
        "dna" : {"143989"},
        "dc" : {"143984"},
        "adsym" : {"161193"},
        "tm" : {"169838"},
        "adtrans" : {"169873"}
        },

    "core_yesterday_media" : {
        "dna" : ["212147", "212148", "212149", "212150"],
        "dc" : ["212152", "212443", "212444", "212445"],
        "adsym" : ["212158", "212457", "212460", "212461"],
        "tm" : ["212153", "212154", "212155", "212157"],
        "adtrans" :["212159", "212434", "212435", "212436"]
        },

    "core_today" : {
        "dna" : {"212013"},
        "dc" : {"212032"},
        "adsym" : {"212037"},
        "tm" : {"212043"},
        "adtrans" :{"212040"}
        },

    "core_today_media" : {
        "dna" : ["212015", "212016", "212017", "212018"],
        "dc" : ["212033", "212437", "212441", "212442"],
        "adsym" : ["212036", "212451", "212452", "212453"],
        "tm" : ["212045", "212046","212047", "212048"],
        "adtrans" : ["212039", "212429", "212430", "212431"]
        },

    "inventoryreport_eom" : {
        "dna" : {"193888"},
        "dc" : {"193891"},
        "adsym" : {"193895"},
        "tm" : {"193899"},
        "adtrans" : {"193903"}
        },

    "market_private_eom" : {
        "dna" : {"193889"},
        "dc" : {"193893"},
        "adsym" : {"193896"},
        "tm" : {"193901"},
        "adtrans" : {"193904"}
        },

    "market_public_eom" : {
        "dna" : {"193890"},
        "dc" : {"193894"},
        "adsym" :{"193897"},
        "tm" : {"193902"},
        "adtrans" : {"193905"}
        }
}    

