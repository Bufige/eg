// =============================================================================
// ------------               > eternal-Games.net <            ------------------
// ------------  Thanks to adri1 for SQLite register system.  ------------------
// ------------  GameMode Zombie edited by: Psychopathic      ------------------
// ------------            #LOS SANTOS APOCALYPTIC            ------------------
// =============================================================================
//============================= [Includes] =====================================
#include <a_samp>
#include <SII>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <foreach>
#include <ColAndreas>
#include <GetVehicleColor>
#include <j_inventory_v2>
#include <GetVehicleName>
#include <OPA>
#include <irc>
#include "../include/gl_common.inc"
#include <objetos>
#include <strlib>
//============================= [Includes] =====================================
//============================= [Settings] =====================================
#define Userfile 														"Admin/Users/%s.ini"
#define snowing                                                         true
#define Version                                                         "0.2"
#define MAX_CONNECTIONS_FROM_IP              							3
#define MAX_STRING 														144 // chat text can hold that much.

#undef  MAX_PLAYERS
#define MAX_PLAYERS                                                     401

#define CPTIME                                                          240000//Time between each checkpoint 240000
new MAX_CP_CLEARED = 6;

#define MAX_CLANS                                                       10
#define MAX_GET_AIRDROP                                                 4

#define ANTI_WEP_HAX_TIMER 												1000*(10) // 10 seconds

#define CPVALUE                                                         300//CPValue, the value of, when it gets reached, it the cp gets cleared. 300
#define DIGTIME                                                         180000//Time of cooldown between digging.
#define VOMITTIME                                                       180000//Time of cooldown between vomitting.

#define KickEx(%0) 														SetTimerEx("KickPlayer", 150, 0, "d", %0)
//============================= [Settings] =====================================
//============================== [RRGGBB] ======================================
#define cwhite                                                          "{EEFFFF}"
#define cligreen                                                        "{44CC22}"
#define cred                                                            "{FF1111}"
#define cgreen                                                          "{05E200}"
#define cblue                                                           "{00B9FF}"
#define cjam                                                            "{E67EF8}"
#define corange                                                         "{FF9600}"
#define cgrey                                                           "{CCCCCC}"
#define cgold                                                           "{FFBB00}"
#define cplat                                                           "{F2F2F2}"
#define cyellow            								    		    "{FFFF00}"
#define cpurple                                                         "{6E00FF}"
//============================== [RRGGBB] ======================================
//============================== [Colors] ======================================
#define red                                                           	0xFF0000FF
#define white                                                           0xFFFFFFFF
#define orange                                                          0xFFA000FF
#define purple                                                          0x6E00FFFF
#define green                                                           0x00FF0AFF
#define gold                                                            0xFFC800FF
#define plat                                                            0xAAAAAAFF
#define Grey 															0xC0C0C0FF
#define COLOR_DARKMAUVE 												0x623778FF
#define COLOR_MAUVE 													0x845F96FF
#define COLOR_INVISIBLE 												0x6E00FF00
//============================== [Colors] ======================================
//============================== [Server config] ===============================
#define function%0(%1)     												forward%0(%1); public%0(%1)

// PRESSED(keys)
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
// HOLDING(keys)
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
// RELEASED(keys)
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
// PRESSING(keyVariable, keys)
#define PRESSING(%0,%1) \
	(%0 & (%1))

#define SendFMessage(%0,%1,%2,%3) 										do{new _str[150]; format(_str,150,%2,%3); SendClientMessage(%0,%1,_str);}while(FALSE)
#define SendFMessageToAll(%1,%2,%3) 									do{new _str[190]; format(_str,150,%2,%3); SendClientMessageToAll(%1,_str);}while(FALSE)
#define SetPlayerHoldingObject(%1,%2,%3,%4,%5,%6,%7,%8,%9) 				SetPlayerAttachedObject(%1,MAX_PLAYER_ATTACHED_OBJECTS-1,%2,%3,%4,%5,%6,%7,%8,%9)
#define StopPlayerHoldingObject(%1) 									RemovePlayerAttachedObject(%1,MAX_PLAYER_ATTACHED_OBJECTS-1)
#define WEAPON_TYPE_NONE 												(0)
#define WEAPON_TYPE_HEAVY   											(1)
#define WEAPON_TYPE_LIGHT   											(2)
#define WEAPON_TYPE_MELEE   											(3)
#define PlayAudioStream(%0,%1,%2)                               		PlayAudioStreamForPlayer(%0,%1); SetTimerEx("UnloadMusic",%2*1000,false,"i",%0);//By Firecat
#undef  MAX_VEHICLES
#define MAX_VEHICLES                                                    100
#define MAX_ITEMS 														20
#define MAX_ITEM_STACK 													99
#define MAX_ITEM_NAME 													24
#define MAX_PING 														1000
#define isEven(%0) 														(!((%0) & 0b1))
#define isOdd(%0) 														!isEven((%0))

#define MAX_SLOTS 														48
//============================== [Server config] ===============================
// ============================= [ IRC ] =======================================
#define BOT_1_NICKNAME "LSA_Bot1"
#define BOT_1_REALNAME "LSA_Bot1"
#define BOT_1_USERNAME "Bot_LSA1"
#define BOT_2_NICKNAME "LSA_Bot2"
#define BOT_2_REALNAME "LSA_Bot2"
#define BOT_2_USERNAME "Bot_LSA2"

#define IRC_SERVER 	"irc.quakenet.org"
#define IRC_PORT 	(6667)
#define IRC_CHANNEL "#eternalGames"
#define MAX_BOTS 	(2)

new
	gBotID[MAX_BOTS],
	gGroupID;

//============================== [Text Draw's] =================================
new Text:GainXPTD[MAX_PLAYERS];
new PlayerText:XPStats[MAX_PLAYERS];
new Text:FuelTD[MAX_PLAYERS];
new Text:OilTD[MAX_PLAYERS];
new PlayerText:XPBox[MAX_PLAYERS][2];
new Text:Infection;
new Text:CPSCleared;
new Text:RoundStats;
new Text:Effect[8];
new Text:CP_Name;
new Text:RadioBox;

new PlayerText:StatsBoxDraw[MAX_PLAYERS],
	Text:StatsBox[2];


new Text:TD_INTRO[6],
	Text:TD_INTRO_MAIN[5],
	Text:TD_INTRO_RULES[4],
	Text:TD_INTRO_GUIDE[3],
	Text:TD_INTRO_PLAY[9],
	PlayerText:PTD_INTRO_PLAY[MAX_PLAYERS][2],
	PlayerText:PTD_INTRO_GUIDE[MAX_PLAYERS],
	DB:Database, DB_Query[1800];
//============================== [Text Draw's] =================================
new dropitem,
	airdropitem,
	PingTimer[MAX_PLAYERS];

new Extra3CPs;

new JailTimer[MAX_PLAYERS];
new Jailed[MAX_PLAYERS];

new String[128], Float:SpecX[MAX_PLAYERS], Float:SpecY[MAX_PLAYERS], Float:SpecZ[MAX_PLAYERS], vWorld[MAX_PLAYERS], Inter[MAX_PLAYERS];
new IsSpecing[MAX_PLAYERS], IsBeingSpeced[MAX_PLAYERS],spectatorid[MAX_PLAYERS];

new ZombieMusic[][] =
{
	"https://www.dropbox.com/s/7607trbqyyienpz/z1.mp3?dl=1",
	"https://www.dropbox.com/s/wiclookwh37xxo9/z2.mp3?dl=1",
	"https://www.dropbox.com/s/f3cxtw9z8i8l6eu/z3.mp3?dl=1",
	"https://www.dropbox.com/s/ob9ymxz4adxrz6g/z4.mp3?dl=1",
	"https://www.dropbox.com/s/bo5exc9t6qs1laz/z5.mp3?dl=1"
};

enum
{
	HUMAN = 1,
	ZOMBIE
};

enum
{
	Registerdialog = 1,
	Logindialog,
	Humanperksdialog,
	Zombieperksdialog,
	Lessbitedialog,
	Flashbangsdialog,
	Burstdialog,
	Inventorydialog,
	Extramedsdialog,
	Extrafueldialog,
	Extraoildialog,
	Medicdialog,
	Morestaminadialog,
	Zombiebaitdialog,
	Firemodedialog,
	Mechanicdialog,
	Extraammodialog,
	Fielddoctordialog,
	Rocketbootsdialog,
	Homingbeacondialog,
	Mastermechanicdialog,
	Flameroundsdialog,
	Luckycharmdialog,
	Grenadesdialog,
	Noperkdialog,
	Nozombieperkdialog,
	Hardbitedialog,
	Diggerdialog,
	Refreshingbitedialog,
	Jumperdialog,
	Hidemodedialog,
	Hardpunchdialog,
	Vomiterdialog,
	Screamerdialog,
	ZBurstrundialog,
	Stingerbitedialog,
	Bigjumperdialog,
	Stompdialog,
	Refreshingbitedialog2,
	Goddigdialog,
	Poppingtiresdialog,
	Higherjumperdialog,
	Repellentdialog,
	Ravagingbitedialog,
	Superscreamdialog,
	Boomerdialog,
	Stealthdialog,
	DIALOG_HIVETP,
	Empty,
 	List,
 	Clickstatsdialog,
 	Rconerrordialog,
 	Ragebandialog,
 	Topplayerdialog,
 	Airdropdialog,
 	DIALOG_ANIMS
};

main(){}
native WP_Hash(buffer[], len, const str[]);
new FALSE = false;

new Float:Locations[6][6] =
{
    {1214.9613,-13.3497,1000.9219,2421.7861,-1225.6342,25.1479},//Pig Pen
	{502.3001,-14.7957,1000.6797,1833.2510,-1681.9969,13.4811},//Alhambra

	{212.5261,-107.4397,1005.1406,2241.1416,-1658.3157,15.2899},//Binco
	{175.3852,-83.6727,1001.8047,1458.4044,-1141.6309,24.0566},//Zip

	{169.1966,-1797.3027,4.1501,173.6723,-1798.2090,4.0596},//beach
	{2164.3032,-1989.0576,14.0276,2163.9861,-1987.4554,13.9685}//Waste industrial
};

new Float:OilFuelSearch[18][3] =
{
	{868.069763, -1171.020874, 16.976562},
	{784.468444, -1808.736206, 13.023437},
	{244.460601, -1768.219116, 4.751395},
	{848.240966, -1720.965820, 14.929687},
	{1226.682128, -1888.518798, 13.739078},
	{1341.790283, -1681.634643, 13.580002},
	{1425.416992, -1291.755371, 13.555937},
	{1237.865722, -898.427368, 42.882812},
	{1752.872802, -1107.372802, 24.078125},
	{1914.014160, -1103.396118, 25.671875},
	{370.691253, -1166.840332, 78.258338},
	{978.887268, -1431.674316, 13.546875},
	{2073.086669, -1576.842529, 13.446692},
	{2386.291259, -1940.564941, 13.546875},
	{833.117126, -1531.652954, 13.644613},
	{2472.859375, -1531.015869, 24.159896},
	{2804.179443, -1241.454711, 45.696376},
	{2785.216064, -1060.705322, 30.719810}
};

new Float:Searchplaces[31][3] =
{
    {255.3864,76.7248,1003.6406},
    {235.4062,74.3358,1005.0391},
    {-20.2721,-52.8958,1003.5469},
    {-18.2101,-50.8218,1003.5469},
    {502.5851,-19.5065,1000.6797},
    {476.1003,-14.7468,1003.6953},
    {2285.4458,-1133.9231,1050.8984},
    {2279.3196,-1135.3746,1050.8984},
    {257.3222,-43.0028,1002.0234},
    {2500.0161,-1706.7634,1014.7422},
    {2500.0164,-1711.2230,1014.7422},
    {2495.2734,-1704.6929,1018.3438},
    {2493.8638,-1700.8329,1018.3438},
    {1210.5579,-15.5985,1000.9219},
    {1215.1836,-15.4792,1000.9219},
    {2342.0168,-1187.5696,1027.9766},
    {2322.7087,-1177.4677,1027.9834},
    {2322.2703,-1172.5985,1027.9766},
    {2348.7813,-1173.9921,1031.9766},
    {380.0800,-57.6338,1001.5078},
    {376.2350,-57.6464,1001.5078},
    {2368.3879,-1134.9847,1050.8750},
    {2361.1465,-1130.8175,1050.8750},
    {2366.8477,-1120.0946,1050.8750},
    {2374.3179,-1128.3701,1050.8750},
    {2337.758300, -1067.500610, 1049.031005},
    {379.141754, -114.362144, 1001.492187},
    {376.746032, -117.278648, 1001.492187},
    {289.829803, -85.760406, 1001.515625},
    {290.345672, -57.436023, 1001.515625},
    {288.216430, -67.210319, 1001.515625}
};

new Float:RandomVS[4][4] =
{
    {2257.878906, -71.085357, 31.601562, 268.837890},
    {2305.682861, 83.276649, 26.478700, 6.805414},
    {2319.548828, -52.346298, 26.484375, 183.733306},
    {2237.710937, 161.664291, 27.257291, 177.154541}
};

new Float:RandomVZ[2][4] =
{
    {2240.148681, -83.622108, 26.500644, 1.103935},
    {2275.655029, 63.365276, 26.484375, 272.499755}
};

new Float:Randomspawns[9][4] =
{
    {1126.2839,-1489.7096,22.7690,227.3781},
    {814.6721,-1616.2850,13.6032,263.0842},
    {330.2045,-1516.2036,35.8672,219.0583},
    {2019.4609,-1436.4253,14.2981,71.6593},
    {2213.3916,-1178.8707,29.7971,4.1820},
    {2379.8376,-1290.6743,24.0000,91.6702},
    {2632.6743,-1751.6016,10.8983,266.9871},
    {1953.2102,-2031.8896,13.5469,266.9979},
    {803.6842,-1342.0836,-0.5078,137.2818}
};

new Float:RandomEnd[10][4] =
{
    {291.6124,-1870.9211,3.8332,2.6989},
    {286.9165,-1870.4952,3.8332,2.0723},
    {288.2404,-1872.1360,6.4023,3.8073},
    {290.3231,-1871.9995,6.4023,359.7339},
    {258.6598,-1871.1213,2.3684,20.9005},
    {266.5316,-1869.8938,2.5840,346.2722},
    {269.9425,-1876.8267,2.2457,355.9013},
    {244.6034,-1871.8011,5.8867,312.8547},
    {246.8585,-1871.6027,5.8867,319.3258},
    {249.5930,-1870.4410,2.3572,324.3268}
};

new Float:Platspawns[4][4] =
{
    {2653.0486,-1387.5162,30.4438,91.7624},
    {2773.9868,-1834.6229,10.3125,199.9468},
    {970.7773,-1829.5486,12.6970,166.8507},
    {348.7736,-1347.1180,14.5078,115.5182}
};

new Float:EndPos[30][4] =
{
    {280.71, -1862.43, 2.01},
	{280.63, -1857.70, 2.01},
	{280.69, -1853.22, 2.01},
	{280.80, -1849.07, 2.01},
	{276.92, -1849.00, 2.01},
	{273.09, -1848.90, 2.01},
	{257.49, -1862.52, 2.01},
	{260.81, -1862.47, 2.01},
	{254.05, -1862.55, 2.01},
	{264.31, -1862.34, 2.01},
	{264.44, -1859.11, 2.01},
	{264.36, -1855.83, 2.01},
	{260.60, -1855.80, 2.01},
	{257.36, -1855.83, 2.01},
	{254.24, -1855.91, 2.01},
	{254.14, -1852.33, 2.01},
	{254.00, -1848.95, 2.01},
	{257.20, -1848.89, 2.01},
	{260.68, -1849.03, 2.01},
	{264.22, -1848.99, 2.01},
	{245.54, -1848.97, 2.01},
	{244.39, -1853.32, 2.01},
	{243.30, -1857.74, 2.01},
	{241.77, -1862.37, 2.01},
	{239.72, -1857.76, 2.01},
	{238.45, -1853.31, 2.01},
	{236.86, -1848.81, 2.01},
	{242.75, -1853.38, 2.01},
	{241.25, -1853.40, 2.01},
	{239.63, -1853.40, 2.01}
};

new ZombieSkins[] =
{
	134,
	135,
	137,
	160,
	162,
	168,
	200,
	212,
	230,
	239
};

new HumansSkins[] =
{
    7, // Humano 12
    1, // Humano 13
	2, // Humano 14
	9, // Humano 15
	10,// Humano 16
	14,// Humano 17
	15, // Humano 18
	13, // Humano 19
	16, // Humano 20
	17, // Humano 21
	18, // Humano 22
	19, // Humano 23
	20, // Humano 24
	21, // Humano 25
	22, // Humano 26
	23, // Humano 27
	24, // Humano 28
	25, // Humano 29
	26, // Humano 30
	27, // Humano 31
	28, // Humano 32
	29, // Humano 33
	30, // Humano 34
	31, // Humano 35
	32, // Humano 36
	33, // Humano 37
	34, // Humano 38
	35, // Humano 39
	36, // Humano 40
	37, // Humano 41
	38, // Humano 42
	39, // Humano 43
	40, // Humano 44
	41, // Humano 45
	43, // Humano 46
	44, // Humano 47
	45, // Humano 48
	46, // Humano 49
	47, // Humano 50
    48, // Humano 51
    49, // Humano 52
    50, // Humano 53
    51, // Humano 54
	52, // Humano 55
	54, // Humano 56
	55, // Humano 57
	56, // Humano 58
	57, // Humano 59
	58, // Humano 60
	59, // Humano 61
	61, // Humano 62
	62, // Humano 63
	30, // Humano 64
	64, // Humano 65
	68, // Humano 66
	69, // Humano 67
	66, // Humano 68
	70, // Humano 69
	72, // Humano 70
	73, // Humano 71
	120, // Humano 72
	76, // Humano 73
	80, // Humano 74
	81, // Humano 75
	82, // Humano 76
	83, // Humano 77
	84, // Humano 78
	85, // Humano 79
	88, // Humano 80
	87, // Humano 81
	89, // Humano 82
	90, // Humano 83
	92, // Humano 84
	93, // Humano 85
	94, // Humano 86
	95, // Humano 87
	96, // Humano 89
	97, // Humano 90
	98, // Humano 91
	99, // Humano 92
	100, // Humano 93
	101, // Humano 94
	102, // Humano 95
	103, // Humano 96
	104, // Humano 97
	105, // Humano 98
	106, // Humano 99
	107, // Humano 100
	108, // Humano 101
	109, // Humano 102
	110, // Humano 103
	111, // Humano 104
	112, // Humano 105
	113, // Humano 106
	114, // Humano 107
	115, // Humano 108
	116, // Humano 109
	117, // Humano 110
	118, // Humano 111
	119, // Humano 112
	120, // Humano 113
	121, // Humano 114
	122, // Humano 115
	123, // Humano 116
	124, // Humano 117
	125, // Humano 118
	126, // Humano 119
	127, // Humano 120
	128, // Humano 121
	130, // Humano 122
	131, // Humano 123
	132, // Humano 124
	133, // Humano 125
	100, // Humano 126
	190, // Humano 127
	136, // Humano 128
	155, // Humano 129
	138, // Humano 130
	139, // Humano 131
	140, // Humano 132
	141, // Humano 133
	142, // Humano 134
	143, // Humano 135
	144, // Humano 136
	145, // Humano 137
	146, // Humano 138
	265, // Humano 139
	266, // Humano 140
	267, // Humano 141
	268, // Humano 142
	269, // Humano 143
	270, // Humano 144
	271, // Humano 145
	272, // Humano 146
	273, // Humano 147
	274, // Humano 148
	275, // Humano 149
	276, // Humano 150
	277, // Humano 151
	278, // Humano 152
	279, // Humano 153
	280, // Humano 154
	281, // Humano 155
	282, // Humano 156
	283, // Humano 157
	284, // Humano 158
	285, // Humano 159
	286, // Humano 160
	287, // Humano 161
	288 // Humano 162
};


enum
{
	CommonRed = 19006,
	CommonOrange,
	CommonGreen,
	CommonBlue,
	CommonPurple,
	CommonEspiral,
	CommonBlack,
	CommonEyes,
	CommonXadrex,
	CommonTransparent,
	CommonXRayVision,
	SquareFormatYellow,
	SquareFormatOrange,
	SquareFormatRed,
	SquareFormatBlue,
	SquareFormatGreen,
	RayBanGray,
	RayBanBlue,
	RayBanPurple,
	RayBanPink,
	RayBanRed,
	RayBanOrange,
	RayBanYellow,
	RayBanGreen,
	CircularNormal,
	CircularYellow,
	CircularRed,
	CircularBlack,
	CircularXadrex,
	CircularThunders,
	CopGlassesBlack = 19138,
	CopGlassesRed = 19139,
	CopGlassesBlue = 19140,
};

/*new invalidskins[] =
{1,2,3,4,5,7,12,15,17,18,21,23,26,27,30,32,33,34,40,41,50,51,60,64,73,76,85,98,103,106,114,118,136,142,148,152,154,157,160,166,172,197,204,207,214,241,245,248,252,254,259,268,269,272,276,277,278,282,283,284,286,287,288,292};*/

enum PlayerInfo
{
	Logged,
	Rank,
	Password[131],
	SSkin,
	ZSkin,
	Warns,
	Warn1[64],
	Warn2[64],
	Warn3[64],
	Banned,
	XP,
	Level,
	Premium,
	Failedlogins,
	Kills,
	Infects,
	Deaths,
	Teamkills,
	Infected,//Dizzy
	Screams,
	CurrentXP,
	ShowingXP,
	SPerk,
	ZPerk,
	CanBite,
 	Dead,
 	JustInfected,
 	Bites,
 	CPCleared,
 	Assists,
 	Vomited,
 	XPToRankUp,
 	Text3D:Ranklabel,
 	Firsttimeincp,
 	CanBurst,
 	ClearBurst,
 	StartCar,
 	Firstspawn,
 	ZombieBait,
 	Float:ZX,
 	Float:ZY,
 	Float:ZZ,
	ZObject,
	ZCount,
	OnFire,
    FireMode,
    FireObject,
    TokeDizzy,
    CanJump,
    CanStomp,
    StompTimer,
    Jumps,
	Flare,
	Flamerounds,
	Searching,
	MolotovMission,
	BettyMission,
	DigTimer,
	CanDig,
	GodDig,
	Lastbite,
	CanRun,
	RunTimer,
	RunTimerActivated,
	Vomit,
	Float:Vomitx,
	Float:Vomity,
	Float:Vomitz,
	Allowedtovomit,
	Vomitmsg,
	Canscream,
	KillsRound,
	DeathsRound,
	InfectsRound,
	Lighton,
	NoPM,
	LastID,
	CanPop,
	LuckyCharm,
	PlantedBettys,
	BettyObj1,
	BettyObj2,
	BettyObj3,
	BettyActive1,
	BettyActive2,
	BettyActive3,
	Bettys,
	oslotglasses,
	oslothat,
	Swimming,
	Muted,
	ClanID,
	ClanLeaderID,

	P_STATUS,
	P_LOGGED,
	P_INTRO_OPTION,
	P_INTRO_SKIN_SELECTED[2],
	P_INTRO_GUIDE_OPTION,

	P_ANTIFLOOD_TICKCOUNT
}

enum
{
	INTRO_MAIN = 1,
	INTRO_PLAY,
	INTRO_GUIDE,
	INTRO_RULES
};

enum
{
	PS_DISCONNECTED,
	PS_CONNECTED,
	PS_CLASS,
	PS_SPAWNED
};

new Team[MAX_PLAYERS];
new PInfo[MAX_PLAYERS][PlayerInfo];

enum ClanInfo
{
	C_ID,
	C_NAME[24],
	C_XP,
	C_KILLS,
	C_INFECTS
}

new CInfo[MAX_CLANS][ClanInfo];

new Weather;
new CPValue;
new CPID;
new CPscleared;
new Fuel[MAX_VEHICLES];
new Oil[MAX_VEHICLES];
new VehicleStarted[MAX_VEHICLES];
new OldWeapon[MAX_PLAYERS];
new HoldingWeapon[MAX_PLAYERS];
new PlayersConnected;
new SnowObj[MAX_PLAYERS][2];
new SnowCreated[MAX_PLAYERS];
new Snow = 0;
new EndObjects[32];
new RoundEnded;
new Mission[MAX_PLAYERS];
new MissionPlace[MAX_PLAYERS][2];

new ServerN;
new CP_Activated;

new
    PMeat[13],
	ZTPS[5],
	TPZone[10];

new Float:pZPos[15][3] = {
	{2606.136230, -1463.581054, 19.009654},
	{1694.141113, -1971.765380, 8.824961},
	{1547.274780, -1636.830566, 6.218750},
	{1294.354125, -1249.394653, 13.600000},
	{1908.839355, -1318.581298, 14.199999},
	{831.413146, -1390.246582, -0.553125},
	{998.767272, -897.245483, 42.300121},
	{2795.812744, -1176.926879, 28.915470},
	{1618.350830, -993.629333, 24.067668},
	{358.485534, -1755.051025, 5.524650},
	{63.665149, 1539.632690, 12.800000},
	{27.856601, 1571.499267, 12.800000},
	{6.460189, 1574.291381, 12.800000},
	{-31.724969, 1502.337280, 12.800000},
	{34.202831, 1486.785034, 12.800000}
};

new Float:RandomSpawnsZombie[4][3] = {
{55.393161, 1514.080932, 12.750000},
{23.437557, 1505.157836, 12.750000},
{15.300825, 1537.107788, 12.750000},
{46.553958, 1547.196411, 12.750000}
};

new
    bool:Activated[MAX_PLAYERS char],
    Hidden[MAX_PLAYERS char],
    CurrentObject[MAX_PLAYERS char]
;
enum
    e_objects
    {
            o_id,           o_n[15],        o_b,
            Float:o_x,      Float:o_y,      Float:o_z,
            Float:o_rx,     Float:o_ry,     Float:o_rz,
            Float:o_sx,     Float:o_sy,     Float:o_sz
    }

enum
    e_dialogs
    {

    }

new
    ObjectInfo[5][e_objects] =
    {
        {1221, "Box 1", 11, 0.331851, -0.387647, 0.108080, 62.871932, 3.603914, 279.105468, 1.500000, 1.500000, 1.500000},
        {1220, "Box 2",11, 0.331851, -0.387647, 0.108080, 62.871932, 3.603914, 279.105468, 1.500000, 1.500000, 1.500000},
        {2912, "Box 3", 10, -0.117735, -0.402220, -0.766344, 356.370971, 357.288360, 5.631556, 1.500000, 1.600000, 1.500000},
        {964, "Army Box", 11, 0.180357, 0.045067, -0.323517, 63.705467, 4.868588, 165.003601, 1.000000, 1.000000, 1.299999},
        {1271, "Gun Box", 11, 0.316308, -0.396371, 0.129949, 65.029396, 4.721271, 279.105468, 1.500000, 1.500000, 1.500000}
    };

new bool:PlayerState[MAX_PLAYERS];

new NotMoving[MAX_PLAYERS],
	WeaponID[MAX_PLAYERS],
	CheckCrouch[MAX_PLAYERS],
	Ammo[MAX_PLAYERS][MAX_SLOTS],
	CBugTimes[MAX_PLAYERS],
	Float:ZPS[MAX_PLAYERS][4],
	TimerBait[MAX_PLAYERS],
	NPCVehicle2,
	NPCVehicle3,
	specweps[MAX_PLAYERS][13][2],
	MRR,
	DBWeapon[MAX_PLAYERS][13],
	DBAmmo[MAX_PLAYERS][13],
	Fakekill[MAX_PLAYERS];

new bool:g_EnterAnim[MAX_PLAYERS char],
	Float:g_Pos[MAX_PLAYERS][3];

new Vhid[MAX_PLAYERS], IsHide[MAX_PLAYERS], PSit[MAX_PLAYERS];

new bool:CanHide[MAX_PLAYERS char],
	bool:HasLeftCP[MAX_PLAYERS char];
/*new
	BunnyHop[MAX_PLAYERS],
	BunnyHopMSG[MAX_PLAYERS];*/

new AnimLibraies[129][14] =
{
	"AIRPORT","Attractors","BAR","BASEBALL","BD_FIRE","BEACH","benchpress","BF_injection","BIKED","BIKEH",
	"BIKELEAP","BIKES","BIKEV","BIKE_DBZ","BLOWJOBZ","BMX","BOMBER","BOX","BSKTBALL","BUDDY","BUS","CAMERA",
	"CAR","CARRY","CAR_CHAT","CASINO","CHAINSAW","CHOPPA","CLOTHES","COACH","COLT45","COP_AMBIENT","COP_DVBYZ",
	"CRACK","CRIB","DAM_JUMP","DANCING","DEALER","DILDO","DODGE","DOZER","DRIVEBYS","FAT","FIGHT_B","FIGHT_C",
	"FIGHT_D","FIGHT_E","FINALE","FINALE2","FLAME","Flowers","FOOD","Freeweights","GANGS","GHANDS","GHETTO_DB",
	"goggles","GRAFFITI","GRAVEYARD","GRENADE","GYMNASIUM","HAIRCUTS","HEIST9","INT_HOUSE","INT_OFFICE",
	"INT_SHOP","JST_BUISNESS","KART","KISSING","KNIFE","LAPDAN1","LAPDAN2","LAPDAN3","LOWRIDER","MD_CHASE",
	"MD_END","MEDIC","MISC","MTB","MUSCULAR","NEVADA","ON_LOOKERS","OTB","PARACHUTE","PARK","PAULNMAC","ped",
	"PLAYER_DVBYS","PLAYIDLES","POLICE","POOL","POOR","PYTHON","QUAD","QUAD_DBZ","RAPPING","RIFLE","RIOT",
	"ROB_BANK","ROCKET","RUSTLER","RYDER","SCRATCHING","SHAMAL","SHOP","SHOTGUN","SILENCED","SKATE","SMOKING",
	"SNIPER","SPRAYCAN","STRIP","SUNBATHE","SWAT","SWEET","SWIM","SWORD","TANK","TATTOOS","TEC","TRAIN","TRUCK",
	"UZI","VAN","VENDING","VORTEX","WAYFARER","WEAPONS","WUZI"
};

new bool:AirDroppedItem[MAX_OBJECTS char],
	bool:HasGettedDropItem[MAX_PLAYERS char],
	RandomItemsAD[MAX_PLAYERS char],
	TimesGettedAirDrop,
	Float:caZAirdrop,
	Float:caZAirdrop2,
	AirDTimer;

new bool:aDuty[MAX_PLAYERS char],
	Float:DutyHealth[MAX_PLAYERS];

new Streaks[MAX_PLAYERS];

new
	Timer,
	Pumpkin,
	Winner,
	Number,
	Minutes,
	PumpkinOn;

new Float: RandomPositions[24][3] = {
	{1767.807861, -1932.837402, 13.595355},
	{2132.916259, -1740.313598, 17.289062},
	{1803.886352, -1590.603881, 14.095897},
	{1485.622680, -1665.684692, 14.610832},
	{1018.429138, -1922.505737, 12.592831},
	{582.102233, -1490.797119, 15.376304},
	{154.038253, -1960.985351, 3.830727},
	{1394.659790, -1897.151977, 13.557967},
	{696.425354, -1661.620483, 3.334803},
	{815.735534, -1273.962280, 16.809768},
	{884.857055, -1021.224548, 31.898437},
	{2019.671508, -1100.481079, 24.752687},
	{2423.918212, -1106.137573, 41.454799},
	{1290.588134, -789.272644, 96.460937},
	{2352.821289, -1819.145019, 13.546875},
	{2673.561523, -1432.989379, 16.257228},
	{2524.559326, -2048.822753, 6.025134},
	{1270.861328, -1630.591308, 27.375000},
	{2205.099853, -990.083679, 63.929687},
	{2963.257324, -1877.590209, 8.781250},
	{2204.633789, -2067.964599, 21.640815},
	{1826.842163, -1415.293457, 29.617187},
	{2520.187988, -1484.259399, 23.997066},
	{723.216430, -1495.780029, 1.934344}
};

static const LocationsName[24][256] = {
	{"El Corona"},
	{"Idlewood"},
	{"Commerce"},
	{"Pershing Square"},
	{"Verona Beach"},
	{"Rodeo"},
	{"Santa Maria Beach"},
	{"Verdant Bluffs"},
	{"Marina"},
	{"Movie Studio"},
	{"Vinewood"},
	{"Glen Park"},
	{"East Los Santos"},
	{"Mansion Madd Dogg"},
	{"Ganton"},
	{"East Beach"},
	{"Willowfield"},
	{"Verona Beach"},
	{"Las Colinas"},
	{"Playa de Seville"},
	{"Willowfield"},
	{"Idlewood"},
	{"East Los Santos"},
	{"Marina"}
};

new AODSkin[MAX_PLAYERS],
	HTimer,
	RandomCPTimer;

public OnGameModeInit()
{
	// Wait 5 seconds for the first bot
	SetTimerEx("IRC_ConnectDelay", 5000, 0, "d", 1);
	// Wait 10 seconds for the second bot
	SetTimerEx("IRC_ConnectDelay", 10000, 0, "d", 2);
	// Create a group (the bots will be added to it upon connect)
	gGroupID = IRC_CreateGroup();

    ConnectNPC("Sgt_Soap","npc2");
    ConnectNPC("Sgt_Nikolai","npc_airdrop");

	NPCVehicle2 = AddStaticVehicle(425, 0, 0, 0, 0, 0, 1);
	NPCVehicle3 = AddStaticVehicle(553, 0, 0, 0, 0, 0, 1);

	SendRconCommand("mapname LS - Zombie");
    SendRconCommand("weburl www.eternal-games.net");
    //SendRconCommand("hostname [eG] Zombie Apocalyptic Outbreak 2.0");
    //SetGameModeText("Zombies VS Humans");

	SendRconCommand("minconnectiontime 	3000");
	SendRconCommand("ackslimit 			5000");

    CA_Init();

	SetTimer("ServerSettings", 10, false);
	SetTimer("UpdateStats", 1000, true);
	SetTimer("Marker", 700, true);
	SetTimer("Dizzy", 60000, true);
	RandomCPTimer = SetTimer("RandomCheckpoint", CPTIME, false);
	//SetTimer("RandomSounds",120000, true);
	SetTimer("FiveSeconds", 3000, true);
	SetTimer("RandomMessage", 500000, true);

	HTimer = SetTimer("HalloweenEvent", 600000, true);
	AirDTimer = SetTimer("AirDropTimer", 1020000, false);
	SetTimer("FakekillT", 600, true);
	SetTimer("anti_wep_hax",ANTI_WEP_HAX_TIMER,true);

    ShowPlayerMarkers(0);
    EnableStuntBonusForAll(0);
	OpenDataBase();
	//WeatherUpdate();
	LoadStaticVehicles();
	AddPlayerClasses();
	ServerObjects();
	ServerPickUps();
	//LimitPlayerMarkerRadius(50.0);
	ShowPlayerMarkers(2);
	CPID = -1;
	CPscleared = 0;
	RoundEnded = 0;
	PumpkinOn = 0;
	Extra3CPs = 0;
	foreach(new i:Player) PInfo[i][Lighton] = false;

	if(fexist("Admin/Teams.txt"))
	{
	    fremove("Admin/Teams.txt");
	    new File:file = fopen("Admin/Teams.txt",io_write);
	    fclose(file);
	}
	else
	{
        new File:file = fopen("Admin/Teams.txt",io_write);
	    fclose(file);
	}
	for(new i; i < MAX_PLAYERS;i++)
	{
		GainXPTD[i] = TextDrawCreate(286.000000, 148.000000, "+10 XP");
		TextDrawBackgroundColor(GainXPTD[i], 255);
		TextDrawFont(GainXPTD[i], 1);
		TextDrawLetterSize(GainXPTD[i], 0.610000, 2.600002);
		TextDrawColor(GainXPTD[i], -1);
		TextDrawSetOutline(GainXPTD[i], 1);
		TextDrawSetProportional(GainXPTD[i], 1);

		FuelTD[i] = TextDrawCreate(221.000000, 421.000000, "Fuel: ~r~~h~ll~y~llllll~g~~h~ll");
		TextDrawBackgroundColor(FuelTD[i], -1499158273);
		TextDrawFont(FuelTD[i], 1);
		TextDrawLetterSize(FuelTD[i], 0.430000, 1.600000);
		TextDrawColor(FuelTD[i], 255);
		TextDrawSetOutline(FuelTD[i], 1);
		TextDrawSetProportional(FuelTD[i], 1);

		OilTD[i] = TextDrawCreate(327.000000, 421.000000, "Oil: ~r~ll~y~llllll~g~~h~ll");
		TextDrawBackgroundColor(OilTD[i], -1499158273);
		TextDrawFont(OilTD[i], 1);
		TextDrawLetterSize(OilTD[i], 0.430000, 1.600000);
		TextDrawColor(OilTD[i], 255);
		TextDrawSetOutline(OilTD[i], 1);
		TextDrawSetProportional(OilTD[i], 1);
	}

	for(new i; i < MAX_VEHICLES; i++)
	{
	    if(i == NPCVehicle2) continue;
	    Fuel[i] = randomEx(10,90);
		Oil[i] = randomEx(10,90);
		new rand = random(2);
		StartVehicle(i,rand);
		VehicleStarted[i] = rand;
	}

	// STATS BOX & FORUM LINK

	StatsBox[0] = TextDrawCreate(545.000000, 361.499908, "_");
	TextDrawLetterSize(StatsBox[0], 0.099374, 7.555826);
	TextDrawTextSize(StatsBox[0], 635.000000, 0.000000);
	TextDrawAlignment(StatsBox[0], 1);
	TextDrawColor(StatsBox[0], -1);
	TextDrawUseBox(StatsBox[0], 1);
	TextDrawBoxColor(StatsBox[0], 60);
	TextDrawSetShadow(StatsBox[0], 216);
	TextDrawSetOutline(StatsBox[0], 0);
	TextDrawBackgroundColor(StatsBox[0], 255);
	TextDrawFont(StatsBox[0], 1);
	TextDrawSetProportional(StatsBox[0], 1);
	TextDrawSetShadow(StatsBox[0], 216);

	StatsBox[1] = TextDrawCreate(550.000000, 352.166748, "eternal-Games.net");
	TextDrawLetterSize(StatsBox[1], 0.287500, 1.337498);
	TextDrawAlignment(StatsBox[1], 1);
	TextDrawColor(StatsBox[1], -1);
	TextDrawSetShadow(StatsBox[1], 0);
	TextDrawSetOutline(StatsBox[1], -1);
	TextDrawBackgroundColor(StatsBox[1], 255);
	TextDrawFont(StatsBox[1], 1);
	TextDrawSetProportional(StatsBox[1], 1);
	TextDrawSetShadow(StatsBox[1], 0);

	// INTRO BY ADRI1
	TD_INTRO[0] = TextDrawCreate(320.000000, -10.000000, "box");
	TextDrawLetterSize(TD_INTRO[0], 0.000000, 11.958357);
	TextDrawTextSize(TD_INTRO[0], 0.000000, 668.000000);
	TextDrawAlignment(TD_INTRO[0], 2);
	TextDrawColor(TD_INTRO[0], -1);
	TextDrawUseBox(TD_INTRO[0], 1);
	TextDrawBoxColor(TD_INTRO[0], 180);
	TextDrawSetShadow(TD_INTRO[0], 0);
	TextDrawSetOutline(TD_INTRO[0], 0);
	TextDrawBackgroundColor(TD_INTRO[0], 255);
	TextDrawFont(TD_INTRO[0], 1);
	TextDrawSetProportional(TD_INTRO[0], 1);
	TextDrawSetShadow(TD_INTRO[0], 0);

	TD_INTRO[1] = TextDrawCreate(320.000000, 350.000000, "box");
	TextDrawLetterSize(TD_INTRO[1], 0.000000, 11.958357);
	TextDrawTextSize(TD_INTRO[1], 0.000000, 668.000000);
	TextDrawAlignment(TD_INTRO[1], 2);
	TextDrawColor(TD_INTRO[1], -1);
	TextDrawUseBox(TD_INTRO[1], 1);
	TextDrawBoxColor(TD_INTRO[1], 180);
	TextDrawSetShadow(TD_INTRO[1], 0);
	TextDrawSetOutline(TD_INTRO[1], 0);
	TextDrawBackgroundColor(TD_INTRO[1], 255);
	TextDrawFont(TD_INTRO[1], 1);
	TextDrawSetProportional(TD_INTRO[1], 1);
	TextDrawSetShadow(TD_INTRO[1], 0);

	TD_INTRO[2] = TextDrawCreate(321.000000, 31.000000, "games");
	TextDrawLetterSize(TD_INTRO[2], 1.083665, 4.615703);
	TextDrawAlignment(TD_INTRO[2], 2);
	TextDrawColor(TD_INTRO[2], -141);
	TextDrawSetShadow(TD_INTRO[2], 0);
	TextDrawSetOutline(TD_INTRO[2], 0);
	TextDrawBackgroundColor(TD_INTRO[2], 255);
	TextDrawFont(TD_INTRO[2], 2);
	TextDrawSetProportional(TD_INTRO[2], 1);
	TextDrawSetShadow(TD_INTRO[2], 0);

	TD_INTRO[3] = TextDrawCreate(321.000000, 68.000000, "Apocalyptic");
	TextDrawLetterSize(TD_INTRO[3], 0.437665, 1.902814);
	TextDrawAlignment(TD_INTRO[3], 2);
	TextDrawColor(TD_INTRO[3], 2105376188);
	TextDrawSetShadow(TD_INTRO[3], 0);
	TextDrawSetOutline(TD_INTRO[3], 1);
	TextDrawBackgroundColor(TD_INTRO[3], 255);
	TextDrawFont(TD_INTRO[3], 0);
	TextDrawSetProportional(TD_INTRO[3], 1);
	TextDrawSetShadow(TD_INTRO[3], 0);

	TD_INTRO[4] = TextDrawCreate(321.000000, 8.000000, "eternal");
	TextDrawLetterSize(TD_INTRO[4], 0.810332, 3.396147);
	TextDrawAlignment(TD_INTRO[4], 2);
	TextDrawColor(TD_INTRO[4], -141);
	TextDrawSetShadow(TD_INTRO[4], 0);
	TextDrawSetOutline(TD_INTRO[4], 0);
	TextDrawBackgroundColor(TD_INTRO[4], 255);
	TextDrawFont(TD_INTRO[4], 2);
	TextDrawSetProportional(TD_INTRO[4], 1);
	TextDrawSetShadow(TD_INTRO[4], 0);

	TD_INTRO[5] = TextDrawCreate(321.000000, 32.000000, "-");
	TextDrawLetterSize(TD_INTRO[5], 20.000000, 1.189332);
	TextDrawAlignment(TD_INTRO[5], 2);
	TextDrawColor(TD_INTRO[5], -2004317998);
	TextDrawSetShadow(TD_INTRO[5], 0);
	TextDrawSetOutline(TD_INTRO[5], 0);
	TextDrawBackgroundColor(TD_INTRO[5], 255);
	TextDrawFont(TD_INTRO[5], 1);
	TextDrawSetProportional(TD_INTRO[5], 1);
	TextDrawSetShadow(TD_INTRO[5], 0);



	TD_INTRO_MAIN[0] = TextDrawCreate(320.000000, 165.000000, "box");
	TextDrawLetterSize(TD_INTRO_MAIN[0], 0.000000, 10.333339);
	TextDrawTextSize(TD_INTRO_MAIN[0], 0.000000, 224.000000);
	TextDrawAlignment(TD_INTRO_MAIN[0], 2);
	TextDrawColor(TD_INTRO_MAIN[0], -1);
	TextDrawUseBox(TD_INTRO_MAIN[0], 1);
	TextDrawBoxColor(TD_INTRO_MAIN[0], 180);
	TextDrawSetShadow(TD_INTRO_MAIN[0], 0);
	TextDrawSetOutline(TD_INTRO_MAIN[0], 0);
	TextDrawBackgroundColor(TD_INTRO_MAIN[0], 255);
	TextDrawFont(TD_INTRO_MAIN[0], 1);
	TextDrawSetProportional(TD_INTRO_MAIN[0], 1);
	TextDrawSetShadow(TD_INTRO_MAIN[0], 0);

	TD_INTRO_MAIN[1] = TextDrawCreate(320.000000, 169.000000, "eternalGames_-_Choose_an_option");
	TextDrawLetterSize(TD_INTRO_MAIN[1], 0.257333, 1.181036);
	TextDrawAlignment(TD_INTRO_MAIN[1], 2);
	TextDrawColor(TD_INTRO_MAIN[1], -187);
	TextDrawSetShadow(TD_INTRO_MAIN[1], 0);
	TextDrawSetOutline(TD_INTRO_MAIN[1], 0);
	TextDrawBackgroundColor(TD_INTRO_MAIN[1], 255);
	TextDrawFont(TD_INTRO_MAIN[1], 1);
	TextDrawSetProportional(TD_INTRO_MAIN[1], 1);
	TextDrawSetShadow(TD_INTRO_MAIN[1], 0);

	TD_INTRO_MAIN[2] = TextDrawCreate(320.000000, 188.000000, "play");
	TextDrawLetterSize(TD_INTRO_MAIN[2], 0.405333, 1.550220);
	TextDrawTextSize(TD_INTRO_MAIN[2], 15.000000, 155.000000);
	TextDrawAlignment(TD_INTRO_MAIN[2], 2);
	TextDrawColor(TD_INTRO_MAIN[2], -126);
	TextDrawUseBox(TD_INTRO_MAIN[2], 1);
	TextDrawBoxColor(TD_INTRO_MAIN[2], 6974087);
	TextDrawSetShadow(TD_INTRO_MAIN[2], 0);
	TextDrawSetOutline(TD_INTRO_MAIN[2], 0);
	TextDrawBackgroundColor(TD_INTRO_MAIN[2], 255);
	TextDrawFont(TD_INTRO_MAIN[2], 3);
	TextDrawSetProportional(TD_INTRO_MAIN[2], 1);
	TextDrawSetShadow(TD_INTRO_MAIN[2], 0);
	TextDrawSetSelectable(TD_INTRO_MAIN[2], true);

	TD_INTRO_MAIN[3] = TextDrawCreate(320.000000, 210.000000, "help_guide");
	TextDrawLetterSize(TD_INTRO_MAIN[3], 0.405333, 1.550220);
	TextDrawTextSize(TD_INTRO_MAIN[3], 15.000000, 155.000000);
	TextDrawAlignment(TD_INTRO_MAIN[3], 2);
	TextDrawColor(TD_INTRO_MAIN[3], -126);
	TextDrawUseBox(TD_INTRO_MAIN[3], 1);
	TextDrawBoxColor(TD_INTRO_MAIN[3], 6974087);
	TextDrawSetShadow(TD_INTRO_MAIN[3], 0);
	TextDrawSetOutline(TD_INTRO_MAIN[3], 0);
	TextDrawBackgroundColor(TD_INTRO_MAIN[3], 255);
	TextDrawFont(TD_INTRO_MAIN[3], 3);
	TextDrawSetProportional(TD_INTRO_MAIN[3], 1);
	TextDrawSetShadow(TD_INTRO_MAIN[3], 0);
	TextDrawSetSelectable(TD_INTRO_MAIN[3], true);

	TD_INTRO_MAIN[4] = TextDrawCreate(320.000000, 232.000000, "read_rules");
	TextDrawLetterSize(TD_INTRO_MAIN[4], 0.405333, 1.550220);
	TextDrawTextSize(TD_INTRO_MAIN[4], 15.000000, 155.000000);
	TextDrawAlignment(TD_INTRO_MAIN[4], 2);
	TextDrawColor(TD_INTRO_MAIN[4], -126);
	TextDrawUseBox(TD_INTRO_MAIN[4], 1);
	TextDrawBoxColor(TD_INTRO_MAIN[4], 6974087);
	TextDrawSetShadow(TD_INTRO_MAIN[4], 0);
	TextDrawSetOutline(TD_INTRO_MAIN[4], 0);
	TextDrawBackgroundColor(TD_INTRO_MAIN[4], 255);
	TextDrawFont(TD_INTRO_MAIN[4], 3);
	TextDrawSetProportional(TD_INTRO_MAIN[4], 1);
	TextDrawSetShadow(TD_INTRO_MAIN[4], 0);
	TextDrawSetSelectable(TD_INTRO_MAIN[4], true);

	TD_INTRO_RULES[0] = TextDrawCreate(320.000000, 158.100006, "box");
	TextDrawLetterSize(TD_INTRO_RULES[0], 0.000000, 14.847716);
	TextDrawTextSize(TD_INTRO_RULES[0], 0.000000, 224.000000);
	TextDrawAlignment(TD_INTRO_RULES[0], 2);
	TextDrawColor(TD_INTRO_RULES[0], -1);
	TextDrawUseBox(TD_INTRO_RULES[0], 1);
	TextDrawBoxColor(TD_INTRO_RULES[0], 180);
	TextDrawSetShadow(TD_INTRO_RULES[0], 0);
	TextDrawSetOutline(TD_INTRO_RULES[0], 0);
	TextDrawBackgroundColor(TD_INTRO_RULES[0], 255);
	TextDrawFont(TD_INTRO_RULES[0], 1);
	TextDrawSetProportional(TD_INTRO_RULES[0], 1);
	TextDrawSetShadow(TD_INTRO_RULES[0], 0);

	TD_INTRO_RULES[1] = TextDrawCreate(320.000000, 162.100006, "eternalGames_-_Rules");
	TextDrawLetterSize(TD_INTRO_RULES[1], 0.257333, 1.181035);
	TextDrawAlignment(TD_INTRO_RULES[1], 2);
	TextDrawColor(TD_INTRO_RULES[1], -187);
	TextDrawSetShadow(TD_INTRO_RULES[1], 0);
	TextDrawSetOutline(TD_INTRO_RULES[1], 0);
	TextDrawBackgroundColor(TD_INTRO_RULES[1], 255);
	TextDrawFont(TD_INTRO_RULES[1], 1);
	TextDrawSetProportional(TD_INTRO_RULES[1], 1);
	TextDrawSetShadow(TD_INTRO_RULES[1], 0);

	TD_INTRO_RULES[2] = TextDrawCreate(320.000000, 181.100006, "_");
	TextDrawLetterSize(TD_INTRO_RULES[2], 0.405333, 11.021025);
	TextDrawTextSize(TD_INTRO_RULES[2], 0.000000, 209.000000);
	TextDrawAlignment(TD_INTRO_RULES[2], 2);
	TextDrawColor(TD_INTRO_RULES[2], -126);
	TextDrawUseBox(TD_INTRO_RULES[2], 1);
	TextDrawBoxColor(TD_INTRO_RULES[2], 6974087);
	TextDrawSetShadow(TD_INTRO_RULES[2], 0);
	TextDrawSetOutline(TD_INTRO_RULES[2], 0);
	TextDrawBackgroundColor(TD_INTRO_RULES[2], 255);
	TextDrawFont(TD_INTRO_RULES[2], 3);
	TextDrawSetProportional(TD_INTRO_RULES[2], 1);
	TextDrawSetShadow(TD_INTRO_RULES[2], 0);
	TextDrawSetSelectable(TD_INTRO_RULES[2], true);

	TD_INTRO_RULES[3] = TextDrawCreate(220.000000, 186.100006, "1._Do_not_bunnyhop.~n~2._Do_not_TeamKill.~n~3._Do_not_use_Cheats.~n~4._Do_not_Jump_+_Med.~n~5._Do_not_Xp_abuse.~n~6._Do_not_Fake-Kills.~n~7._Do_not_Bait_Bug.~n~8._Do_not_insult,_RESPECT.");
	TextDrawLetterSize(TD_INTRO_RULES[3], 0.257333, 1.181035);
	TextDrawAlignment(TD_INTRO_RULES[3], 1);
	TextDrawColor(TD_INTRO_RULES[3], -187);
	TextDrawSetShadow(TD_INTRO_RULES[3], 0);
	TextDrawSetOutline(TD_INTRO_RULES[3], 0);
	TextDrawBackgroundColor(TD_INTRO_RULES[3], 255);
	TextDrawFont(TD_INTRO_RULES[3], 1);
	TextDrawSetProportional(TD_INTRO_RULES[3], 1);
	TextDrawSetShadow(TD_INTRO_RULES[3], 0);

	TD_INTRO_GUIDE[0] = TextDrawCreate(320.000000, 134.000000, "box");
	TextDrawLetterSize(TD_INTRO_GUIDE[0], 0.000000, 18.879184);
	TextDrawTextSize(TD_INTRO_GUIDE[0], 0.000000, 309.000000);
	TextDrawAlignment(TD_INTRO_GUIDE[0], 2);
	TextDrawColor(TD_INTRO_GUIDE[0], -1);
	TextDrawUseBox(TD_INTRO_GUIDE[0], 1);
	TextDrawBoxColor(TD_INTRO_GUIDE[0], 180);
	TextDrawSetShadow(TD_INTRO_GUIDE[0], 0);
	TextDrawSetOutline(TD_INTRO_GUIDE[0], 0);
	TextDrawBackgroundColor(TD_INTRO_GUIDE[0], 255);
	TextDrawFont(TD_INTRO_GUIDE[0], 1);
	TextDrawSetProportional(TD_INTRO_GUIDE[0], 1);
	TextDrawSetShadow(TD_INTRO_GUIDE[0], 0);

	TD_INTRO_GUIDE[1] = TextDrawCreate(320.000000, 138.000000, "eternalGames_-_Help_guide");
	TextDrawLetterSize(TD_INTRO_GUIDE[1], 0.257333, 1.181035);
	TextDrawAlignment(TD_INTRO_GUIDE[1], 2);
	TextDrawColor(TD_INTRO_GUIDE[1], -187);
	TextDrawSetShadow(TD_INTRO_GUIDE[1], 0);
	TextDrawSetOutline(TD_INTRO_GUIDE[1], 0);
	TextDrawBackgroundColor(TD_INTRO_GUIDE[1], 255);
	TextDrawFont(TD_INTRO_GUIDE[1], 1);
	TextDrawSetProportional(TD_INTRO_GUIDE[1], 1);
	TextDrawSetShadow(TD_INTRO_GUIDE[1], 0);

	TD_INTRO_GUIDE[2] = TextDrawCreate(320.000000, 157.000000, "_");
	TextDrawLetterSize(TD_INTRO_GUIDE[2], 0.406332, 15.546738);
	TextDrawTextSize(TD_INTRO_GUIDE[2], 0.000000, 300.000000);
	TextDrawAlignment(TD_INTRO_GUIDE[2], 2);
	TextDrawColor(TD_INTRO_GUIDE[2], -126);
	TextDrawUseBox(TD_INTRO_GUIDE[2], 1);
	TextDrawBoxColor(TD_INTRO_GUIDE[2], 6974087);
	TextDrawSetShadow(TD_INTRO_GUIDE[2], 0);
	TextDrawSetOutline(TD_INTRO_GUIDE[2], 0);
	TextDrawBackgroundColor(TD_INTRO_GUIDE[2], 255);
	TextDrawFont(TD_INTRO_GUIDE[2], 3);
	TextDrawSetProportional(TD_INTRO_GUIDE[2], 1);
	TextDrawSetShadow(TD_INTRO_GUIDE[2], 0);
	TextDrawSetSelectable(TD_INTRO_GUIDE[2], true);

	TD_INTRO_PLAY[0] = TextDrawCreate(320.000000, 117.051872, "box");
	TextDrawLetterSize(TD_INTRO_PLAY[0], 0.000000, 23.500005);
	TextDrawTextSize(TD_INTRO_PLAY[0], 0.000000, 310.000000);
	TextDrawAlignment(TD_INTRO_PLAY[0], 2);
	TextDrawColor(TD_INTRO_PLAY[0], -1);
	TextDrawUseBox(TD_INTRO_PLAY[0], 1);
	TextDrawBoxColor(TD_INTRO_PLAY[0], 180);
	TextDrawSetShadow(TD_INTRO_PLAY[0], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[0], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[0], 255);
	TextDrawFont(TD_INTRO_PLAY[0], 1);
	TextDrawSetProportional(TD_INTRO_PLAY[0], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[0], 0);

	TD_INTRO_PLAY[1] = TextDrawCreate(320.000000, 128.051864, "eternalGames_-_Team_selection");
	TextDrawLetterSize(TD_INTRO_PLAY[1], 0.257333, 1.181035);
	TextDrawAlignment(TD_INTRO_PLAY[1], 2);
	TextDrawColor(TD_INTRO_PLAY[1], -176);
	TextDrawSetShadow(TD_INTRO_PLAY[1], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[1], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[1], 255);
	TextDrawFont(TD_INTRO_PLAY[1], 1);
	TextDrawSetProportional(TD_INTRO_PLAY[1], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[1], 0);

	TD_INTRO_PLAY[2] = TextDrawCreate(320.000000, 224.051834, "vs");
	TextDrawLetterSize(TD_INTRO_PLAY[2], 0.400000, 1.600000);
	TextDrawAlignment(TD_INTRO_PLAY[2], 2);
	TextDrawColor(TD_INTRO_PLAY[2], -186);
	TextDrawSetShadow(TD_INTRO_PLAY[2], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[2], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[2], 255);
	TextDrawFont(TD_INTRO_PLAY[2], 3);
	TextDrawSetProportional(TD_INTRO_PLAY[2], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[2], 0);

	TD_INTRO_PLAY[3] = TextDrawCreate(214.000000, 268.051910, "<");
	TextDrawLetterSize(TD_INTRO_PLAY[3], 0.345665, 1.799111);
	TextDrawTextSize(TD_INTRO_PLAY[3], 15.000000, 47.000000);
	TextDrawAlignment(TD_INTRO_PLAY[3], 2);
	TextDrawColor(TD_INTRO_PLAY[3], -128);
	TextDrawUseBox(TD_INTRO_PLAY[3], 1);
	TextDrawBoxColor(TD_INTRO_PLAY[3], 8947840);
	TextDrawSetShadow(TD_INTRO_PLAY[3], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[3], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[3], 255);
	TextDrawFont(TD_INTRO_PLAY[3], 1);
	TextDrawSetProportional(TD_INTRO_PLAY[3], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[3], 0);
	TextDrawSetSelectable(TD_INTRO_PLAY[3], true);

	TD_INTRO_PLAY[4] = TextDrawCreate(268.000000, 268.051910, ">");
	TextDrawLetterSize(TD_INTRO_PLAY[4], 0.345665, 1.799111);
	TextDrawTextSize(TD_INTRO_PLAY[4], 15.000000, 47.319946);
	TextDrawAlignment(TD_INTRO_PLAY[4], 2);
	TextDrawColor(TD_INTRO_PLAY[4], -128);
	TextDrawUseBox(TD_INTRO_PLAY[4], 1);
	TextDrawBoxColor(TD_INTRO_PLAY[4], 8947840);
	TextDrawSetShadow(TD_INTRO_PLAY[4], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[4], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[4], 255);
	TextDrawFont(TD_INTRO_PLAY[4], 1);
	TextDrawSetProportional(TD_INTRO_PLAY[4], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[4], 0);
	TextDrawSetSelectable(TD_INTRO_PLAY[4], true);

	TD_INTRO_PLAY[5] = TextDrawCreate(241.000000, 291.051910, "Zombie");
	TextDrawLetterSize(TD_INTRO_PLAY[5], 0.356000, 1.653924);
	TextDrawTextSize(TD_INTRO_PLAY[5], 15.000000, 100.789527);
	TextDrawAlignment(TD_INTRO_PLAY[5], 2);
	TextDrawColor(TD_INTRO_PLAY[5], -128);
	TextDrawUseBox(TD_INTRO_PLAY[5], 1);
	TextDrawBoxColor(TD_INTRO_PLAY[5], 8947840);
	TextDrawSetShadow(TD_INTRO_PLAY[5], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[5], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[5], 255);
	TextDrawFont(TD_INTRO_PLAY[5], 1);
	TextDrawSetProportional(TD_INTRO_PLAY[5], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[5], 0);
	TextDrawSetSelectable(TD_INTRO_PLAY[5], true);

	TD_INTRO_PLAY[6] = TextDrawCreate(371.000000, 268.051910, "<");
	TextDrawLetterSize(TD_INTRO_PLAY[6], 0.345665, 1.799111);
	TextDrawTextSize(TD_INTRO_PLAY[6], 15.000000, 47.000000);
	TextDrawAlignment(TD_INTRO_PLAY[6], 2);
	TextDrawColor(TD_INTRO_PLAY[6], -128);
	TextDrawUseBox(TD_INTRO_PLAY[6], 1);
	TextDrawBoxColor(TD_INTRO_PLAY[6], 8947840);
	TextDrawSetShadow(TD_INTRO_PLAY[6], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[6], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[6], 255);
	TextDrawFont(TD_INTRO_PLAY[6], 1);
	TextDrawSetProportional(TD_INTRO_PLAY[6], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[6], 0);
	TextDrawSetSelectable(TD_INTRO_PLAY[6], true);

	TD_INTRO_PLAY[7] = TextDrawCreate(425.000000, 268.051910, ">");
	TextDrawLetterSize(TD_INTRO_PLAY[7], 0.345665, 1.799111);
	TextDrawTextSize(TD_INTRO_PLAY[7], 15.000000, 47.319946);
	TextDrawAlignment(TD_INTRO_PLAY[7], 2);
	TextDrawColor(TD_INTRO_PLAY[7], -128);
	TextDrawUseBox(TD_INTRO_PLAY[7], 1);
	TextDrawBoxColor(TD_INTRO_PLAY[7], 8947840);
	TextDrawSetShadow(TD_INTRO_PLAY[7], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[7], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[7], 255);
	TextDrawFont(TD_INTRO_PLAY[7], 1);
	TextDrawSetProportional(TD_INTRO_PLAY[7], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[7], 0);
	TextDrawSetSelectable(TD_INTRO_PLAY[7], true);

	TD_INTRO_PLAY[8] = TextDrawCreate(398.000000, 292.051910, "Human");
	TextDrawLetterSize(TD_INTRO_PLAY[8], 0.356000, 1.653924);
	TextDrawTextSize(TD_INTRO_PLAY[8], 15.000000, 100.789527);
	TextDrawAlignment(TD_INTRO_PLAY[8], 2);
	TextDrawColor(TD_INTRO_PLAY[8], -128);
	TextDrawUseBox(TD_INTRO_PLAY[8], 1);
	TextDrawBoxColor(TD_INTRO_PLAY[8], 8947840);
	TextDrawSetShadow(TD_INTRO_PLAY[8], 0);
	TextDrawSetOutline(TD_INTRO_PLAY[8], 0);
	TextDrawBackgroundColor(TD_INTRO_PLAY[8], 255);
	TextDrawFont(TD_INTRO_PLAY[8], 1);
	TextDrawSetProportional(TD_INTRO_PLAY[8], 1);
	TextDrawSetShadow(TD_INTRO_PLAY[8], 0);
	TextDrawSetSelectable(TD_INTRO_PLAY[8], true);

	CPSCleared = TextDrawCreate(500.625000, 98.416671, "~w~Checkpoints_cleared____~r~0~w~/6");
	TextDrawLetterSize(CPSCleared, 0.228124, 1.605834);
	TextDrawAlignment(CPSCleared, 1);
	TextDrawColor(CPSCleared, -1);
	TextDrawSetShadow(CPSCleared, 0);
	TextDrawSetOutline(CPSCleared, -1);
	TextDrawBackgroundColor(CPSCleared, 255);
	TextDrawFont(CPSCleared, 2);
	TextDrawSetProportional(CPSCleared, 1);
	TextDrawSetShadow(CPSCleared, 0);

    RadioBox = TextDrawCreate(502.500000, 115.999748, "RADIO_BATTERY:_200/200");
	TextDrawLetterSize(RadioBox, 0.184999, 0.678332);
	TextDrawTextSize(RadioBox, 628.000000, 0.000000);
	TextDrawAlignment(RadioBox, 1);
	TextDrawColor(RadioBox, -1);
	TextDrawUseBox(RadioBox, 1);
	TextDrawBoxColor(RadioBox, 80);
	TextDrawSetShadow(RadioBox, 0);
	TextDrawSetOutline(RadioBox, 1);
	TextDrawBackgroundColor(RadioBox, 255);
	TextDrawFont(RadioBox, 2);
	TextDrawSetProportional(RadioBox, 1);
	TextDrawSetShadow(RadioBox, 0);


	CP_Name = TextDrawCreate(502.500000, 128.799606, "CP:_No_Signal");
	TextDrawLetterSize(CP_Name, 0.184999, 0.678333);
	TextDrawTextSize(CP_Name, 628.000000, 0.000000);
	TextDrawAlignment(CP_Name, 1);
	TextDrawColor(CP_Name, -1);
	TextDrawUseBox(CP_Name, 1);
	TextDrawBoxColor(CP_Name, 80);
	TextDrawSetShadow(CP_Name, 0);
	TextDrawSetOutline(CP_Name, 1);
	TextDrawBackgroundColor(CP_Name, 255);
	TextDrawFont(CP_Name, 2);
	TextDrawSetProportional(CP_Name, 1);
	TextDrawSetShadow(CP_Name, 0);

	Infection = TextDrawCreate(501.250000, 136.216720, "infection____34%");
	TextDrawLetterSize(Infection, 0.228123, 1.605834);
	TextDrawAlignment(Infection, 1);
	TextDrawColor(Infection, -1);
	TextDrawSetShadow(Infection, 0);
	TextDrawSetOutline(Infection, -1);
	TextDrawBackgroundColor(Infection, 255);
	TextDrawFont(Infection, 2);
	TextDrawSetProportional(Infection, 1);
	TextDrawSetShadow(Infection, 0);

	RoundStats = TextDrawCreate(262.000000, 352.000000, "Most Kills: [Yak]Kyo_Masuyo ~n~Most Deaths: [Yak]Kyo_Masuyo ~n~Most Infects: [Yak]Kyo_Masuyo");
	TextDrawBackgroundColor(RoundStats, 255);
	TextDrawFont(RoundStats, 1);
	TextDrawLetterSize(RoundStats, 0.410000, 1.500000);
	TextDrawColor(RoundStats, -1);
	TextDrawSetOutline(RoundStats, 0);
	TextDrawSetProportional(RoundStats, 1);
	TextDrawSetShadow(RoundStats, 1);
	TextDrawUseBox(RoundStats, 1);
	TextDrawBoxColor(RoundStats, 80);
	TextDrawTextSize(RoundStats, 406.000000, 50.000000);

	Effect[0] = TextDrawCreate(1.000000,1.000000,"________________________________________________________________________________________________________________________________");
	TextDrawUseBox(Effect[0],1);
	TextDrawBoxColor(Effect[0],0xffffffff);
	TextDrawTextSize(Effect[0],950.000000,0.000000);
	TextDrawAlignment(Effect[0],0);
	TextDrawBackgroundColor(Effect[0],0x000000ff);
	TextDrawFont(Effect[0],3);
	TextDrawLetterSize(Effect[0],1.000000,70.000000);
	TextDrawColor(Effect[0],0xffffffff);
	TextDrawSetOutline(Effect[0],1);
	TextDrawSetProportional(Effect[0],1);
	TextDrawSetShadow(Effect[0],1);

	Effect[1] = TextDrawCreate(1.000000,1.000000,"________________________________________________________________________________________________________________________________");
	TextDrawUseBox(Effect[1],1);
	TextDrawBoxColor(Effect[1],0xffffffcc);
	TextDrawTextSize(Effect[1],950.000000,0.000000);
	TextDrawAlignment(Effect[1],0);
	TextDrawBackgroundColor(Effect[1],0x000000ff);
	TextDrawFont(Effect[1],3);
	TextDrawLetterSize(Effect[1],1.000000,70.000000);
	TextDrawColor(Effect[1],0xffffffff);
	TextDrawSetOutline(Effect[1],1);
	TextDrawSetProportional(Effect[1],1);
	TextDrawSetShadow(Effect[1],1);

	Effect[2] = TextDrawCreate(1.000000,1.000000,"________________________________________________________________________________________________________________________________");
	TextDrawUseBox(Effect[2],1);
	TextDrawBoxColor(Effect[2],0xffffff99);
	TextDrawTextSize(Effect[2],950.000000,0.000000);
	TextDrawAlignment(Effect[2],0);
	TextDrawBackgroundColor(Effect[2],0x000000ff);
	TextDrawFont(Effect[2],3);
	TextDrawLetterSize(Effect[2],1.000000,70.000000);
	TextDrawColor(Effect[2],0xffffffff);
	TextDrawSetOutline(Effect[2],1);
	TextDrawSetProportional(Effect[2],1);
	TextDrawSetShadow(Effect[2],1);

	Effect[3] = TextDrawCreate(1.000000,1.000000,"________________________________________________________________________________________________________________________________");
	TextDrawUseBox(Effect[3],1);
	TextDrawBoxColor(Effect[3],0xffffff66);
	TextDrawTextSize(Effect[3],950.000000,0.000000);
	TextDrawAlignment(Effect[3],0);
	TextDrawBackgroundColor(Effect[3],0x000000ff);
	TextDrawFont(Effect[3],3);
	TextDrawLetterSize(Effect[3],1.000000,70.000000);
	TextDrawColor(Effect[3],0xffffffff);
	TextDrawSetOutline(Effect[3],1);
	TextDrawSetProportional(Effect[3],1);
	TextDrawSetShadow(Effect[3],1);

	Effect[4] = TextDrawCreate(1.000000,1.000000,"________________________________________________________________________________________________________________________________");
	TextDrawUseBox(Effect[4],1);
	TextDrawBoxColor(Effect[4],0xffffff33);
	TextDrawTextSize(Effect[4],950.000000,0.000000);
	TextDrawAlignment(Effect[4],0);
	TextDrawBackgroundColor(Effect[4],0x000000ff);
	TextDrawFont(Effect[4],3);
	TextDrawLetterSize(Effect[4],1.000000,70.000000);
	TextDrawColor(Effect[4],0xffffffff);
	TextDrawSetOutline(Effect[4],1);
	TextDrawSetProportional(Effect[4],1);
	TextDrawSetShadow(Effect[4],1);

	Effect[5] = TextDrawCreate(1.000000,1.000000,"________________________________________________________________________________________________________________________________");
	TextDrawUseBox(Effect[5],1);
	TextDrawBoxColor(Effect[5],0xffffff22);
	TextDrawTextSize(Effect[5],950.000000,0.000000);
	TextDrawAlignment(Effect[5],0);
	TextDrawBackgroundColor(Effect[5],0x000000ff);
	TextDrawFont(Effect[5],3);
	TextDrawLetterSize(Effect[5],1.000000,70.000000);
	TextDrawColor(Effect[5],0xffffffff);
	TextDrawSetOutline(Effect[5],1);
	TextDrawSetProportional(Effect[5],1);
	TextDrawSetShadow(Effect[5],1);

	Effect[6] = TextDrawCreate(1.000000,1.000000,"________________________________________________________________________________________________________________________________");
	TextDrawUseBox(Effect[6],1);
	TextDrawBoxColor(Effect[6],0xffffff11);
	TextDrawTextSize(Effect[6],950.000000,0.000000);
	TextDrawAlignment(Effect[6],0);
	TextDrawBackgroundColor(Effect[6],0x000000ff);
	TextDrawFont(Effect[6],3);
	TextDrawLetterSize(Effect[6],1.000000,70.000000);
	TextDrawColor(Effect[6],0xffffffff);
	TextDrawSetOutline(Effect[6],1);
	TextDrawSetProportional(Effect[6],1);
	TextDrawSetShadow(Effect[6],1);

	Effect[7] = TextDrawCreate(1.000000,1.000000,"________________________________________________________________________________________________________________________________");
	TextDrawUseBox(Effect[7],1);
	TextDrawBoxColor(Effect[7],0xffffff11);
	TextDrawTextSize(Effect[7],950.000000,0.000000);
	TextDrawAlignment(Effect[7],0);
	TextDrawBackgroundColor(Effect[7],0x000000ff);
	TextDrawFont(Effect[7],3);
	TextDrawLetterSize(Effect[7],1.000000,70.000000);
	TextDrawColor(Effect[7],0xffffffff);
	TextDrawSetOutline(Effect[7],1);
	TextDrawSetProportional(Effect[7],1);
	TextDrawSetShadow(Effect[7],1);
	return 1;
}

OpenDataBase()
{
	Database = db_open("SERVER/Database.db");

    format(DB_Query, sizeof(DB_Query), "");
    strcat(DB_Query, "CREATE TABLE IF NOT EXISTS USERS (");
	strcat(DB_Query, "ID INTEGER PRIMARY KEY AUTOINCREMENT,");
	strcat(DB_Query, "NAME TEXT DEFAULT '',");
	strcat(DB_Query, "PASS TEXT DEFAULT '',");
	strcat(DB_Query, "IP TEXT DEFAULT '',");
	strcat(DB_Query, "LEVEL INTEGER DEFAULT 0,");
	strcat(DB_Query, "RANK INTEGER DEFAULT 0,");
	strcat(DB_Query, "XP INTEGER DEFAULT 0,");
	strcat(DB_Query, "KILLS INTEGER DEFAULT 0,");
	strcat(DB_Query, "DEATHS INTEGER DEFAULT 0,");
	strcat(DB_Query, "TEAMKILLS INTEGER DEFAULT 0,");
	strcat(DB_Query, "INFECTS INTEGER DEFAULT 0,");
	strcat(DB_Query, "SPERK INTEGER DEFAULT 0,");
	strcat(DB_Query, "ZPERK INTEGER DEFAULT 0,");
	strcat(DB_Query, "BITES INTEGER DEFAULT 0,");
	strcat(DB_Query, "CPCLEARED INTEGER DEFAULT 0,");
	strcat(DB_Query, "VOMITED INTEGER DEFAULT 0,");
	strcat(DB_Query, "ASSISTS INTEGER DEFAULT 0,");
	strcat(DB_Query, "PREMIUM INTEGER DEFAULT 0,");
	strcat(DB_Query, "SSKIN INTEGER DEFAULT 0,");
	strcat(DB_Query, "ZSKIN INTEGER DEFAULT 0,");
	strcat(DB_Query, "WARNS INTEGER DEFAULT 0,");
	strcat(DB_Query, "BANNED INTEGER DEFAULT 0,");
	strcat(DB_Query, "WARN1 TEXT DEFAULT '',");
	strcat(DB_Query, "WARN2 TEXT DEFAULT '',");
	strcat(DB_Query, "WARN3 TEXT DEFAULT '',");
	strcat(DB_Query, "SCREAMS INTEGER DEFAULT 0,");
	strcat(DB_Query, "MUTED INTEGER DEFAULT 0)");

	//db_query(Database, "UPDATE CLANS SET XP =  WHERE ID = '1'");
 	format(DB_Query, sizeof(DB_Query), "");
    strcat(DB_Query, "CREATE TABLE IF NOT EXISTS CLANS (");
	strcat(DB_Query, "ID INTEGER PRIMARY KEY AUTOINCREMENT,");
	strcat(DB_Query, "NAME TEXT DEFAULT '',");
	strcat(DB_Query, "XP INTEGER DEFAULT 0,");
	strcat(DB_Query, "KILLS INTEGER DEFAULT 0,");
	strcat(DB_Query, "INFECTS INTEGER DEFAULT 0)");
	/*format(DB_Query, sizeof(DB_Query), "");
	strcat(DB_Query, "ALTER TABLE USERS ADD COLUMN CLANLEADERID INTEGER DEFAULT 0");*/

	db_query(Database, DB_Query);
	return 1;
}

function IRC_ConnectDelay(tempid)
{
	switch (tempid)
	{
		case 1:
		{
			// Connect the first bot
			gBotID[0] = IRC_Connect(IRC_SERVER, IRC_PORT, BOT_1_NICKNAME, BOT_1_REALNAME, BOT_1_USERNAME);
		}
		case 2:
		{
			// Connect the second bot
			gBotID[1] = IRC_Connect(IRC_SERVER, IRC_PORT, BOT_2_NICKNAME, BOT_2_REALNAME, BOT_2_USERNAME);
		}
	}
	return 1;
}

public OnGameModeExit()
{
    IRC_Quit(gBotID[0], "GameMode exiting");
	// Disconnect the second bot
	IRC_Quit(gBotID[1], "GameMode exiting");
	// Destroy the group
	IRC_DestroyGroup(gGroupID);

    RoundEnded = 0;
    KillTimer(AirDTimer);
    KillTimer(Timer);
    for(new i; i < MAX_PLAYERS;i++)
	{
	   	DestroyDynamicObject(SnowObj[i][0]);
	   	DestroyDynamicObject(SnowObj[i][1]);
	   	StopAudioStreamForPlayer(i);
	}
	for( new i = 0; i < 2048; i++ )
	{
	   if(i != INVALID_TEXT_DRAW) continue;
	   TextDrawHideForAll(Text: i);
	   TextDrawDestroy(Text: i);
	}
	for(new i; i < sizeof(EndPos);i++)
	{
	    DestroyObject(EndObjects[i]);
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(PInfo[playerid][P_STATUS] == PS_CONNECTED)
	{
        TogglePlayerSpectating(playerid, true);
		Streamer_UpdateEx(playerid, 1545.3540, -1612.0858, 13.2768);
		//SetPlayerPos(playerid, 1545.3540, -1612.0858, 13.2768);
		//SetPlayerFacingAngle(playerid,180.554626);
		InterpolateCameraPos(playerid, 1531.7229, -1628.3605, 18.8296, 1537.3767, -1637.6245, 18.8296, 45000);
		InterpolateCameraLookAt(playerid, 1532.5765, -1627.8431, 18.6192, 1538.2301, -1637.1072, 18.6092, 45000);

		SetPlayerTime(playerid, 7, 0);
		SetPlayerWeather(playerid, 9);

		PInfo[playerid][P_STATUS] = PS_CLASS;

		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		SendClientMessage(playerid,0x9AB8FFFF, " ");
		//SendClientMessage(playerid,0x15EC4DFF, "{CCCCCC}eternalGames: Los Santos Apocalyptic.");

		for(new i = 0; i != sizeof TD_INTRO; i ++) TextDrawShowForPlayer(playerid, TD_INTRO[i]);

		new DBResult:Result;
		format(DB_Query, sizeof(DB_Query), "SELECT PASS, BANNED FROM USERS WHERE NAME = '%s'", GetPName(playerid));
		Result = db_query(Database, DB_Query);
		if(db_num_rows(Result))
		{
			db_get_field(Result, 0, PInfo[playerid][Password], 131);
			PInfo[playerid][Banned] = db_get_field_int(Result, 1);
			if(PInfo[playerid][Banned])
			{
				new file[128];
				SendFMessageToAll(red,"[Anti Ban Evade] %s has tried to ban evade, therefor he has been banned.",GetPName(playerid));
				format(file,sizeof file,"%s has tried to ban evade.",GetPName(playerid));
				SaveIn("Banevadelog", file, 1);
				SetTimerEx("BanPlayer", 100, false, "i", playerid);
			}
			else
			{
				ShowPlayerDialog(playerid,Logindialog,3,""cwhite"Login",""cwhite"Welcome back!\nPlease type in your password to "cligreen"load "cwhite"your status \n",">>","Cancel");
			}
		}
		else
		{
			ShowPlayerDialog(playerid,Registerdialog,3,""cwhite"Register your account",""cwhite"Welcome to our server.\nThis account "cligreen"isn't registered.\n\n"cwhite"Type in a password to play.",">>","Cancel");
		}
		db_free_result(Result);
		return 1;
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
  	{
	  	new npcname[MAX_PLAYER_NAME];
	  	GetPlayerName(playerid, npcname, sizeof(npcname));
	  	if(!strcmp(npcname, "Sgt_Soap", true))
    	{
    	    new enginem, lights, alarm, doors, bonnet, boot, objective;

	    	new Text3D:label = Create3DTextLabel("Sgt_Soap", green, 30.0, 40.0, 50.0, 40.0, 0);
	    	Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 1.5);
	      	PutPlayerInVehicle(playerid, NPCVehicle2, 0);

			GetVehicleParamsEx(NPCVehicle2, enginem, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(NPCVehicle2, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
      	}
      	if(!strcmp(npcname, "Sgt_Nikolai", true))
    	{
    	    SetPlayerColor(playerid, GetPlayerColor(playerid) & ~0xFF);
    	    new enginem, lights, alarm, doors, bonnet, boot, objective;

	    	new Text3D:label = Create3DTextLabel("Sgt_Nikolai", green, 30.0, 40.0, 50.0, 40.0, 0);
	    	Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 1.5);
	      	PutPlayerInVehicle(playerid, NPCVehicle3, 0);

			GetVehicleParamsEx(NPCVehicle3, enginem, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(NPCVehicle3, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
      	}
  		return 1;
  	}

	if(!GetPVarType(playerid, "anims_loaded"))
	SetPVarInt(playerid, "anims_loaded", 1);
	for(new a=0; a < 129; a++) ApplyAnimation(playerid,AnimLibraies[a],"null",0.0,0,0,0,0,0);

	PInfo[playerid][P_STATUS] = PS_SPAWNED;
	PingTimer[playerid] = SetTimerEx("CheckPing", 10000, 1, "i", playerid);
    SetPlayerTime(playerid, 0, 0);
    PlayerState[playerid] = true;

	if(PInfo[playerid][Firstspawn] == 1)
	{
	    PlayerTextDrawShow(playerid, XPBox[playerid][0]);
		PlayerTextDrawShow(playerid, XPBox[playerid][1]);
		PlayerTextDrawShow(playerid, XPStats[playerid]);
		PlayerTextDrawShow(playerid, StatsBoxDraw[playerid]);

		TextDrawShowForPlayer(playerid,CPSCleared);
		TextDrawShowForPlayer(playerid,Infection);
		TextDrawShowForPlayer(playerid,CP_Name);
		TextDrawShowForPlayer(playerid,RadioBox);
		TextDrawShowForPlayer(playerid,StatsBox[0]);
		TextDrawShowForPlayer(playerid,StatsBox[1]);

		CheckRankup(playerid);
	    PInfo[playerid][Firstspawn] = 0;
	}

  	if(Extra3CPs == 1)
    {
        if(Team[playerid] == HUMAN)
		{
			if(IsSpecing[playerid] == 1)
			{
				SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);
				SetPlayerInterior(playerid,Inter[playerid]);
				SetPlayerVirtualWorld(playerid,vWorld[playerid]);
				IsSpecing[playerid] = 0;
				IsBeingSpeced[spectatorid[playerid]] = 0;
				CheckRankup(playerid);
				for(new w=0; w < 13; w++) GivePlayerWeapon(playerid, specweps[playerid][w][0], specweps[playerid][w][1]);

				if(PInfo[playerid][SSkin] != 0 && PInfo[playerid][Premium] > 0)	{
				    SetPlayerSkin(playerid, PInfo[playerid][SSkin]); }
				else {
					SetPlayerSkin(playerid, HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]); }
				return 1;
			}

		    if(PInfo[playerid][SPerk] == 19) GivePlayerWeapon(playerid,16,3);
		    ResetPlayerInventory(playerid);
			new rand = random(sizeof RandomVS);
			SetPlayerPos(playerid,RandomVS[rand][0], RandomVS[rand][1], RandomVS[rand][2]);
			SetPlayerFacingAngle(playerid,RandomVS[rand][3]);
			SetCameraBehindPlayer(playerid);
			CheckRankup(playerid,1);
			SetPlayerColor(playerid,green);

			SetPlayerWeather(playerid, 9);
			SetPlayerTime(playerid, 0, 0);

			if(PInfo[playerid][Premium] == 0)
	  		{
				AddItem(playerid,"Small Medical Kits",5);
			    AddItem(playerid,"Medium Medical Kits",4);
		        AddItem(playerid,"Large Medical Kits",3);
		        AddItem(playerid,"Fuel",3);
		        AddItem(playerid,"Oil",3);
		        AddItem(playerid,"Flashlight",3);
		    }
		    if(PInfo[playerid][Premium] == 1)
		    {
		        SetPlayerArmour(playerid,100);
			    AddItem(playerid,"Small Medical Kits",15);
		     	AddItem(playerid,"Medium Medical Kits",15);
			    AddItem(playerid,"Large Medical Kits",15);
			    AddItem(playerid,"Fuel",15);
			    AddItem(playerid,"Oil",15);
			    AddItem(playerid,"Flashlight",15);
			    AddItem(playerid,"Dizzy Pills",15);
				/*new file[80];
				format(file,sizeof file,Userfile,GetPName(playerid));
				INI_Open(file);
				SetPlayerSkin(playerid,INI_ReadInt("SSkin"));
				INI_Close();*/
				new DBResult:Result;
				format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
				Result = db_query(Database, DB_Query);
				if(db_num_rows(Result))
				{
					PInfo[playerid][SSkin] = db_get_field_int(Result, 18);
				}
				db_free_result(Result);
				if(PInfo[playerid][SSkin] != 0)	{
				    SetPlayerSkin(playerid, PInfo[playerid][SSkin]); }
				else {
					SetPlayerSkin(playerid, HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]); }
		    }
		    if(PInfo[playerid][Premium] == 2)
		    {
		        SetPlayerArmour(playerid,150);
			    AddItem(playerid,"Small Medical Kits",24);
		     	AddItem(playerid,"Medium Medical Kits",24);
			    AddItem(playerid,"Large Medical Kits",24);
			    AddItem(playerid,"Fuel",24);
			    AddItem(playerid,"Oil",24);
			    AddItem(playerid,"Flashlight",24);
			    AddItem(playerid,"Dizzy Pills",24);
			    AddItem(playerid,"Molotovs Guide",1);
			    AddItem(playerid,"Bouncing Bettys Guide",1);
			    /*new file[80];
				format(file,sizeof file,Userfile,GetPName(playerid));
				INI_Open(file);
				SetPlayerSkin(playerid,INI_ReadInt("SSkin"));
				INI_Close();*/
				new DBResult:Result;
				format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
				Result = db_query(Database, DB_Query);
				if(db_num_rows(Result))
				{
					PInfo[playerid][SSkin] = db_get_field_int(Result, 18);
				}
				db_free_result(Result);

				if(PInfo[playerid][SSkin] != 0)	{
				    SetPlayerSkin(playerid, PInfo[playerid][SSkin]); }
				else {
					SetPlayerSkin(playerid, HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]); }

				//rand = random(sizeof Platspawns);
				//SetPlayerPos(playerid,Platspawns[rand][0],Platspawns[rand][1],Platspawns[rand][2]);
				//SetPlayerFacingAngle(playerid,Platspawns[rand][3]);
		    }
			//PutGlassesOn(playerid);
			//PutHatOn(playerid);
		}
	    if(Team[playerid] == ZOMBIE)
	    {
	   		if(IsSpecing[playerid] == 1)
			{
				SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);
				SetPlayerInterior(playerid,Inter[playerid]);
				SetPlayerVirtualWorld(playerid,vWorld[playerid]);
				IsSpecing[playerid] = 0;
				IsBeingSpeced[spectatorid[playerid]] = 0;

				if(PInfo[playerid][ZSkin] != 0 && PInfo[playerid][Premium] > 0)	{
				    SetPlayerSkin(playerid, PInfo[playerid][ZSkin]); }
				else {
					SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]); }

				return 1;
			}
			if(PInfo[playerid][JustInfected] == 1)
		    {
		        //print("Infect 1");
		        SetSpawnInfo(playerid, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2], ZPS[playerid][3], 0, 0, 0, 0, 0, 0);
		        if(PInfo[playerid][Premium] == 1 || PInfo[playerid][Premium] == 2) {
			        if(PInfo[playerid][ZSkin] != 0)	{
				    	SetPlayerSkin(playerid, PInfo[playerid][ZSkin]); }
					else {
						SetPlayerSkin(playerid, ZombieSkins[random(sizeof(ZombieSkins))]);  }
				}
		        SetPlayerSkin(playerid, ZombieSkins[random(sizeof(ZombieSkins))]);
		        PInfo[playerid][JustInfected] = 0;
	    	    SetPlayerColor(playerid,purple);
			    SetPlayerArmour(playerid,0);
			    SetPlayerHealth(playerid,150.0);
		        //InfectPlayer(playerid);
		        return 1;
			}

			SetPlayerWeather(playerid, 9);
			SetPlayerTime(playerid, 6, 0);
			Team[playerid] = ZOMBIE;

		    TimerBait[playerid] = SetTimerEx("BaitEffect", 700, true, "i", playerid);

		    if(PInfo[playerid][Premium] == 1 || PInfo[playerid][Premium] == 2)
		    {
				new DBResult:Result;
				format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
				Result = db_query(Database, DB_Query);
				if(db_num_rows(Result))
				{
					PInfo[playerid][ZSkin] = db_get_field_int(Result, 18);
				}
				if(PInfo[playerid][ZSkin] != 0)	{
			    	SetPlayerSkin(playerid, PInfo[playerid][ZSkin]); }
				else {
					SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]); }

				db_free_result(Result);
		    }
		    SetPlayerColor(playerid,purple);
		    SetPlayerArmour(playerid,0);
		    SetPlayerHealth(playerid,150.0);
		    SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]);
   			new rand = random(sizeof RandomVZ);
			SetPlayerPos(playerid,RandomVZ[rand][0], RandomVZ[rand][1], RandomVZ[rand][2]);
			SetPlayerFacingAngle(playerid,RandomVZ[rand][3]);
	    }
        return 1;
	}

  	for(new p; p<sizeof pZPos; p++)
	{
		if(Team[playerid] == ZOMBIE) SetPlayerMapIcon(playerid, p, pZPos[p][0], pZPos[p][1], pZPos[p][2], 42, 0, MAPICON_GLOBAL);
	}

   	new isvisib = GetPVarInt(playerid,"PISVisible");
    if(isvisib == 1)
    {
		SetPVarInt(playerid,"PISVisible",0);
		PutPlayerInVehicle(playerid, Vhid[playerid], PSit[playerid]);
		return 1;
    }

	for(new p; p<sizeof pZPos; p++)
	{
		if(Team[playerid] == ZOMBIE) SetPlayerMapIcon(playerid, p, pZPos[p][0], pZPos[p][1], pZPos[p][2], 42, 0, MAPICON_GLOBAL);
	}

	if(Team[playerid] == HUMAN)
	{
		if(IsSpecing[playerid] == 1)
		{
			SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);
			SetPlayerInterior(playerid,Inter[playerid]);
			SetPlayerVirtualWorld(playerid,vWorld[playerid]);
			IsSpecing[playerid] = 0;
			IsBeingSpeced[spectatorid[playerid]] = 0;
			CheckRankup(playerid);
			for(new w=0; w < 13; w++) GivePlayerWeapon(playerid, specweps[playerid][w][0], specweps[playerid][w][1]);

			if(PInfo[playerid][SSkin] != 0 && PInfo[playerid][Premium] > 0)	{
			    SetPlayerSkin(playerid, PInfo[playerid][SSkin]); }
			else {
				SetPlayerSkin(playerid, HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]); }
			return 1;
		}

	    if(PInfo[playerid][SPerk] == 19) GivePlayerWeapon(playerid,16,3);
	    ResetPlayerInventory(playerid);
		new rand = random(sizeof Randomspawns);
		SetPlayerPos(playerid,Randomspawns[rand][0],Randomspawns[rand][1],Randomspawns[rand][2]);
		SetPlayerFacingAngle(playerid,Randomspawns[rand][3]);
		SetCameraBehindPlayer(playerid);
		CheckRankup(playerid,1);
		SetPlayerColor(playerid,green);

		SetPlayerWeather(playerid, 9);
		SetPlayerTime(playerid, 0, 0);

		if(PInfo[playerid][Premium] == 0)
  		{
			AddItem(playerid,"Small Medical Kits",5);
		    AddItem(playerid,"Medium Medical Kits",4);
	        AddItem(playerid,"Large Medical Kits",3);
	        AddItem(playerid,"Fuel",3);
	        AddItem(playerid,"Oil",3);
	        AddItem(playerid,"Flashlight",3);
	    }
	    if(PInfo[playerid][Premium] == 1)
	    {
	        SetPlayerArmour(playerid,100);
		    AddItem(playerid,"Small Medical Kits",15);
	     	AddItem(playerid,"Medium Medical Kits",15);
		    AddItem(playerid,"Large Medical Kits",15);
		    AddItem(playerid,"Fuel",15);
		    AddItem(playerid,"Oil",15);
		    AddItem(playerid,"Flashlight",15);
		    AddItem(playerid,"Dizzy Pills",15);
			/*new file[80];
			format(file,sizeof file,Userfile,GetPName(playerid));
			INI_Open(file);
			SetPlayerSkin(playerid,INI_ReadInt("SSkin"));
			INI_Close();*/
			new DBResult:Result;
			format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
			Result = db_query(Database, DB_Query);
			if(db_num_rows(Result))
			{
				PInfo[playerid][SSkin] = db_get_field_int(Result, 18);
			}
			db_free_result(Result);
			if(PInfo[playerid][SSkin] != 0)	{
			    SetPlayerSkin(playerid, PInfo[playerid][SSkin]); }
			else {
				SetPlayerSkin(playerid, HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]); }
	    }
	    if(PInfo[playerid][Premium] == 2)
	    {
	        SetPlayerArmour(playerid,150);
		    AddItem(playerid,"Small Medical Kits",24);
	     	AddItem(playerid,"Medium Medical Kits",24);
		    AddItem(playerid,"Large Medical Kits",24);
		    AddItem(playerid,"Fuel",24);
		    AddItem(playerid,"Oil",24);
		    AddItem(playerid,"Flashlight",24);
		    AddItem(playerid,"Dizzy Pills",24);
		    AddItem(playerid,"Molotovs Guide",1);
		    AddItem(playerid,"Bouncing Bettys Guide",1);
		    /*new file[80];
			format(file,sizeof file,Userfile,GetPName(playerid));
			INI_Open(file);
			SetPlayerSkin(playerid,INI_ReadInt("SSkin"));
			INI_Close();*/
			new DBResult:Result;
			format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
			Result = db_query(Database, DB_Query);
			if(db_num_rows(Result))
			{
				PInfo[playerid][SSkin] = db_get_field_int(Result, 18);
			}
			db_free_result(Result);

			if(PInfo[playerid][SSkin] != 0)	{
			    SetPlayerSkin(playerid, PInfo[playerid][SSkin]); }
			else {
				SetPlayerSkin(playerid, HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]); }

			rand = random(sizeof Platspawns);
			SetPlayerPos(playerid,Platspawns[rand][0],Platspawns[rand][1],Platspawns[rand][2]);
			SetPlayerFacingAngle(playerid,Platspawns[rand][3]);
	    }
		//PutGlassesOn(playerid);
		//PutHatOn(playerid);
	}
    if(Team[playerid] == ZOMBIE)
    {
   		if(IsSpecing[playerid] == 1)
		{
			SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);
			SetPlayerInterior(playerid,Inter[playerid]);
			SetPlayerVirtualWorld(playerid,vWorld[playerid]);
			IsSpecing[playerid] = 0;
			IsBeingSpeced[spectatorid[playerid]] = 0;

			if(PInfo[playerid][ZSkin] != 0 && PInfo[playerid][Premium] > 0)	{
			    SetPlayerSkin(playerid, PInfo[playerid][ZSkin]); }
			else {
				SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]); }

			return 1;
		}
		if(PInfo[playerid][JustInfected] == 1)
	    {
	        //print("Infect 1");
	        SetSpawnInfo(playerid, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2], ZPS[playerid][3], 0, 0, 0, 0, 0, 0);
	        if(PInfo[playerid][Premium] == 1 || PInfo[playerid][Premium] == 2) {
		        if(PInfo[playerid][ZSkin] != 0)	{
			    	SetPlayerSkin(playerid, PInfo[playerid][ZSkin]); }
				else {
					SetPlayerSkin(playerid, ZombieSkins[random(sizeof(ZombieSkins))]);  }
			}
	        SetPlayerSkin(playerid, ZombieSkins[random(sizeof(ZombieSkins))]);
	        PInfo[playerid][JustInfected] = 0;
    	    SetPlayerColor(playerid,purple);
		    SetPlayerArmour(playerid,0);
		    SetPlayerHealth(playerid,150.0);
	        //InfectPlayer(playerid);
	        return 1;
		}

		TogglePlayerControllable(playerid, false);
		GameTextForPlayer(playerid, "~w~Loading objects, wait..", 4000, 4);
		SetTimerEx("ObjectsLoaded", 4000, 0, "i", playerid);

		SetPlayerWeather(playerid, 9);
		SetPlayerTime(playerid, 6, 0);
		Team[playerid] = ZOMBIE;

	    TimerBait[playerid] = SetTimerEx("BaitEffect", 700, true, "i", playerid);

	    if(PInfo[playerid][Premium] == 1 || PInfo[playerid][Premium] == 2)
	    {
			new DBResult:Result;
			format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
			Result = db_query(Database, DB_Query);
			if(db_num_rows(Result))
			{
				PInfo[playerid][ZSkin] = db_get_field_int(Result, 18);
			}
			if(PInfo[playerid][ZSkin] != 0)	{
		    	SetPlayerSkin(playerid, PInfo[playerid][ZSkin]); }
			else {
				SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]); }

			db_free_result(Result);
	    }
	    SetPlayerColor(playerid,purple);
	    SetPlayerArmour(playerid,0);
	    SetPlayerHealth(playerid,150.0);
	    SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]);
	    new rand = random(sizeof(RandomSpawnsZombie));
		SetPlayerPos(playerid, RandomSpawnsZombie[rand][0], RandomSpawnsZombie[rand][1], RandomSpawnsZombie[rand][2]);
    }

	StopAudioStreamForPlayer(playerid);
	PInfo[playerid][Dead] = 0;
	SetPlayerCP(playerid);
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
 	if(PInfo[playerid][Logged] == 0) return 0;
	return 1;
}

public OnPlayerDeath(playerid,killerid,reason)
{
	if(IsPlayerNPC(killerid) || IsPlayerNPC(playerid)) return 1;
	/*      Anti Fake Kill        */
 	Fakekill[playerid]++;
    /*----------------------------*/
    g_EnterAnim{playerid} = false;
    PInfo[playerid][Dead] = 1;
    PInfo[playerid][DeathsRound]++;

   	if(IsBeingSpeced[playerid] == 1)
	{
	    for(new i=0; i < MAX_PLAYERS; i++)
	    {
	    	if(spectatorid[i] == playerid)
			{
				TogglePlayerSpectating(i, false);
			}
		}
	}

	Streaks[playerid] = 0;

	if(Mission[playerid] != 0)
	{
    	RemovePlayerMapIcon(playerid,1);
    	Mission[playerid] = 0;
    	SendClientMessage(playerid,red,"You have failed to make your molotov/betty's mission.");
 	}
    if(PInfo[playerid][Lighton] == 1)
	{
		RemovePlayerAttachedObject(playerid,3);
		RemovePlayerAttachedObject(playerid,4);
        PInfo[playerid][Lighton] = 0;
        RemoveItem(playerid,"Flashlight",1);
        new string[90];
 		format(string,sizeof string,""cjam"%s has dropped his flashlight.",GetPName(playerid));
		SendNearMessage(playerid,white,string,30);
	}
	if(Team[playerid] == HUMAN && PInfo[playerid][Infected] == 1)
	{
	    InfectPlayer(playerid);
	}
	if(Team[killerid] == HUMAN && Team[playerid] == HUMAN)
	{
	    if(PInfo[playerid][Infected] == 1)
	    {
	    	GetPlayerPos(playerid, ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2]);
		    GetPlayerFacingAngle(playerid, ZPS[playerid][3]);
		    SetSpawnInfo(playerid, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2], ZPS[playerid][3], 0, 0, 0, 0, 0, 0);

			PInfo[killerid][Kills]++;
	        GivePlayerXP(killerid);
        	CheckRankup(killerid);
        	//InfectPlayer(playerid);

	     	PInfo[playerid][Deaths]++;
			PInfo[playerid][Infected] = 0;
			PInfo[playerid][Dead] = 1;

			SpawnPlayer(playerid);

		    Team[playerid] = ZOMBIE;
		    GameTextForPlayer(playerid,"~r~~h~Infected!",4000,3);

		    SetPlayerColor(playerid, purple);
			PInfo[playerid][DeathsRound]++;

			SendFMessageToAll(0xA4A4A4FF, "** %s has been infected.", GetPName(playerid));

			new string[200];
			format(string,sizeof(string),"04*** %s has been infected.", GetPName(playerid));
			IRC_GroupSay(gGroupID, IRC_CHANNEL, string);

		    new string2[45];
	    	if(PInfo[playerid][Premium] == 1) {
				format(string2,sizeof string2,""cgold"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }
			else if(PInfo[playerid][Premium] == 2) {
			    format(string2,sizeof string2,""cplat"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }
			else {
			    format(string2,sizeof string2,""cpurple"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }

			Update3DTextLabelText(PInfo[playerid][Ranklabel],0x00E800FF,string2);
		}
	    else
	    {
        	PInfo[killerid][Teamkills]++;
        	SendClientMessage(killerid,white,"» "cred"Team killing is not allowed! "cwhite"«");
        	PInfo[playerid][Deaths]++;
        	CheckRankup(playerid);
    	}
	}
	if(Team[killerid] == HUMAN && Team[playerid] == ZOMBIE)
	{
	    if(PInfo[playerid][ZPerk] == 20)
	    {
	        new Float:POSJ[3];
			GetPlayerPos(playerid,POSJ[0],POSJ[1],POSJ[2]);
			CreateExplosion(POSJ[0],POSJ[1],POSJ[2], 6, 5.0);
		}
	    PInfo[killerid][Kills]++;
	    PInfo[playerid][Deaths]++;
	    PInfo[killerid][KillsRound]++;

	    SetTimerEx("StreakTimer", 1250, false, "ii", playerid, killerid);

	    GivePlayerXP(killerid);
	    CheckRankup(killerid);

	    if(PInfo[killerid][ClanID] != 0)
		{
			CInfo[PInfo[killerid][ClanID]][C_KILLS]++;
			SaveClanStats(PInfo[killerid][ClanID]);
		}
	}
	if(Team[killerid] == ZOMBIE && Team[playerid] == HUMAN)
	{
		GetPlayerPos(playerid, ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2]);
	    GetPlayerFacingAngle(playerid, ZPS[playerid][3]);
	    SetSpawnInfo(playerid, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2], ZPS[playerid][3], 0, 0, 0, 0, 0, 0);

	    GivePlayerXP(killerid);
	    CheckRankup(killerid);
    	//InfectPlayer(playerid);

        PInfo[killerid][Infects]++;
     	PInfo[playerid][Deaths]++;
		PInfo[playerid][Infected] = 0;
		PInfo[playerid][Dead] = 1;

		if(PInfo[killerid][ClanID] != 0)
		{
			CInfo[PInfo[killerid][ClanID]][C_INFECTS]++;
			SaveClanStats(PInfo[killerid][ClanID]);
		}

		SpawnPlayer(playerid);

	    Team[playerid] = ZOMBIE;
	    GameTextForPlayer(playerid,"~r~~h~Infected!",4000,3);

	    SetPlayerColor(playerid, purple);
		PInfo[playerid][DeathsRound]++;

		SendFMessageToAll(0xA4A4A4FF, "** %s has been infected.", GetPName(playerid));

		new string[200];
		format(string,sizeof(string),"04*** %s has been infected.", GetPName(playerid));
		IRC_GroupSay(gGroupID, IRC_CHANNEL, string);

	    new string2[45];
    	if(PInfo[playerid][Premium] == 1) {
			format(string2,sizeof string2,""cgold"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }
		else if(PInfo[playerid][Premium] == 2) {
		    format(string2,sizeof string2,""cplat"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }
		else {
		    format(string2,sizeof string2,""cpurple"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }

		Update3DTextLabelText(PInfo[playerid][Ranklabel],0x00E800FF,string2);

	    //SendFMessageToAll(0xA4A4A4FF, "** %s has been infected.", GetPName(playerid));
	}

	new
		msg[128],
		killerName[MAX_PLAYER_NAME],
		reasonMsg[32],
		playerName[MAX_PLAYER_NAME];
	GetPlayerName(killerid, killerName, sizeof(killerName));
	GetPlayerName(playerid, playerName, sizeof(playerName));
	if (killerid != INVALID_PLAYER_ID)
	{
		switch (reason)
		{
			case 0:
			{
				reasonMsg = "Unarmed";
			}
			case 1:
			{
				reasonMsg = "Brass Knuckles";
			}
			case 2:
			{
				reasonMsg = "Golf Club";
			}
			case 3:
			{
				reasonMsg = "Night Stick";
			}
			case 4:
			{
				reasonMsg = "Knife";
			}
			case 5:
			{
				reasonMsg = "Baseball Bat";
			}
			case 6:
			{
				reasonMsg = "Shovel";
			}
			case 7:
			{
				reasonMsg = "Pool Cue";
			}
			case 8:
			{
				reasonMsg = "Katana";
			}
			case 9:
			{
				reasonMsg = "Chainsaw";
			}
			case 10:
			{
				reasonMsg = "Dildo";
			}
			case 11:
			{
				reasonMsg = "Dildo";
			}
			case 12:
			{
				reasonMsg = "Vibrator";
			}
			case 13:
			{
				reasonMsg = "Vibrator";
			}
			case 14:
			{
				reasonMsg = "Flowers";
			}
			case 15:
			{
				reasonMsg = "Cane";
			}
			case 22:
			{
				reasonMsg = "Dual Pistols (COLT)";
			}
			case 23:
			{
				reasonMsg = "Silenced Pistol";
			}
			case 24:
			{
				reasonMsg = "Desert Eagle";
			}
			case 25:
			{
				reasonMsg = "Shotgun";
			}
			case 26:
			{
				reasonMsg = "Sawn-off Shotgun";
			}
			case 27:
			{
				reasonMsg = "Combat Shotgun";
			}
			case 28:
			{
				reasonMsg = "MAC-10";
			}
			case 29:
			{
				reasonMsg = "MP5";
			}
			case 30:
			{
				reasonMsg = "AK-47";
			}
			case 31:
			{
				if (GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
				{
					switch (GetVehicleModel(GetPlayerVehicleID(killerid)))
					{
						case 447:
						{
							reasonMsg = "Sea Sparrow Machine Gun";
						}
						default:
						{
							reasonMsg = "Assault Rifle";
						}
					}
				}
				else
				{
					reasonMsg = "Assault Rifle";
				}
			}
			case 32:
			{
				reasonMsg = "MAC-10";
			}
			case 33:
			{
				reasonMsg = "Rifle";
			}
			case 34:
			{
				reasonMsg = "Sniper";
			}
			case 37:
			{
				reasonMsg = "Fire";
			}
			case 38:
			{
				if (GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
				{
					switch (GetVehicleModel(GetPlayerVehicleID(killerid)))
					{
						case 425:
						{
							reasonMsg = "Helicopter";
						}
						default:
						{
							reasonMsg = "Minigun";
						}
					}
				}
				else
				{
					reasonMsg = "Minigun";
				}
			}
			case 41:
			{
				reasonMsg = "Spray";
			}
			case 42:
			{
				reasonMsg = "Extintor";
			}
			case 49:
			{
				reasonMsg = "Collision";
			}
			case 50:
			{
				if (GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
				{
					switch (GetVehicleModel(GetPlayerVehicleID(killerid)))
					{
						case 417, 425, 447, 465, 469, 487, 488, 497, 501, 548, 563:
						{
							reasonMsg = "Propellers";
						}
						default:
						{
							reasonMsg = "Collision";
						}
					}
				}
				else
				{
					reasonMsg = "Collision";
				}
			}
			case 51:
			{
				if (GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
				{
					switch (GetVehicleModel(GetPlayerVehicleID(killerid)))
					{
						case 425:
						{
							reasonMsg = "Hunter";
						}
						case 432:
						{
							reasonMsg = "Tank";
						}
						case 520:
						{
							reasonMsg = "Hydra";
						}
						default:
						{
							reasonMsg = "Explosion";
						}
					}
				}
				else
				{
					reasonMsg = "Explosion";
				}
			}
			default:
			{
				reasonMsg = "Unknown Wep";
			}
		}
		format(msg, sizeof(msg), "04*** %s has killed %s. (%s)", killerName, playerName, reasonMsg);
	}
	else
	{
		switch (reason)
		{
			case 53:
			{
				format(msg, sizeof(msg), "04*** %s died. (Swimming)", playerName);
			}
			case 54:
			{
				format(msg, sizeof(msg), "04*** %s died. (Collision)", playerName);
			}
			default:
			{
				format(msg, sizeof(msg), "04*** %s died.", playerName);
			}
		}
	}
	IRC_GroupSay(gGroupID, IRC_CHANNEL, msg);

	TextDrawHideForPlayer(playerid,FuelTD[playerid]);
	TextDrawHideForPlayer(playerid,OilTD[playerid]);
	SaveStats(playerid);
	SaveStats(killerid);
	return 1;
}

public OnPlayerDisconnect(playerid,reason)
{
    if(IsPlayerNPC(playerid)) return 1;
	if(PInfo[playerid][Logged] == 1) SaveStats(playerid);

	if(IsBeingSpeced[playerid] == 1)
	{
	    for(new i=0; i < MAX_PLAYERS; i++)
	    {
	    	if(spectatorid[i] == playerid)
			{
				TogglePlayerSpectating(i, false);
			}
		}
	}

	new string[64];
	switch(reason)
    {
        case 0: format(string,sizeof string,"» "cred"%s has left the server. (Timed out)",GetPName(playerid));
        case 1: format(string,sizeof string,"» "cred"%s has left the server. (Leaving)",GetPName(playerid));
        case 2: format(string,sizeof string,"» "cred"%s has left the server. (Kicked/Banned)",GetPName(playerid));
    }
    
        new
		leaveMsg[128],
		name[MAX_PLAYER_NAME],
		reasonMsg[8];
	switch(reason)
	{
		case 0:
		{
			reasonMsg = "Time Out";
		}
		case 1:
		{
			reasonMsg = "Leaving";
		}
		case 2:
		{
			reasonMsg = "Kicked/Banned";
		}
	}
	GetPlayerName(playerid, name, sizeof(name));
	format(leaveMsg, sizeof(leaveMsg), "02[%d] 03*** %s has left the server. (%s)", playerid, name, reasonMsg);
	IRC_GroupSay(gGroupID, IRC_CHANNEL, leaveMsg);
    
    StopAudioStreamForPlayer(playerid);
    KillTimer(TimerBait[playerid]);
    KillTimer(PingTimer[playerid]);
    Streaks[playerid] = 0;
    PInfo[playerid][Lighton] = false;
    PInfo[playerid][KillsRound] = 0;
    PInfo[playerid][InfectsRound] = 0;
    PInfo[playerid][DeathsRound] = 0;
    PInfo[playerid][RunTimerActivated] = 0;
    PInfo[playerid][PlantedBettys] = 0;
    PInfo[playerid][Bettys] = 0;
    PInfo[playerid][BettyActive1] = 0;
    PInfo[playerid][BettyActive2] = 0;
    PInfo[playerid][BettyActive3] = 0;
    CurrentObject{playerid} = 0xFFFF;
    Activated{playerid} = false;
    PlayersConnected--;
    SendAdminMessage(white,string);
    DestroyObject(PInfo[playerid][FireObject]);
    DestroyObject(PInfo[playerid][BettyObj1]);
    DestroyObject(PInfo[playerid][BettyObj2]);
    DestroyObject(PInfo[playerid][BettyObj3]);
    Delete3DTextLabel(PInfo[playerid][Ranklabel]);
    RemovePlayerMapIcon(playerid,0);
	DestroyObject(PInfo[playerid][Flare]);
	DestroyObject(PInfo[playerid][Vomit]);
	RemovePlayerAttachedObject(playerid,3);
	RemovePlayerAttachedObject(playerid,4);
	KillTimer(PInfo[playerid][StompTimer]);
	KillTimer(PInfo[playerid][RunTimer]);
	KillTimer(PInfo[playerid][DigTimer]);

	PlayerTextDrawDestroy(playerid, PTD_INTRO_PLAY[playerid][0]);
	PlayerTextDrawDestroy(playerid, PTD_INTRO_PLAY[playerid][1]);
	PlayerTextDrawDestroy(playerid, PTD_INTRO_GUIDE[playerid]);
	PInfo[playerid][P_STATUS] = PS_DISCONNECTED;
	PInfo[playerid][P_LOGGED] = false;
	PInfo[playerid][P_INTRO_OPTION] = 0;
	PInfo[playerid][P_INTRO_SKIN_SELECTED][0] = 0;
	PInfo[playerid][P_INTRO_SKIN_SELECTED][1] = 0;
	PInfo[playerid][P_INTRO_GUIDE_OPTION] = 0;

	for(new p; p<sizeof pZPos; p++) RemovePlayerMapIcon(playerid, p);
	for(new g = 0; g < 2; g++) DestroyDynamicObject(SnowObj[playerid][g]);

    if(CPID != -1) DisablePlayerCheckpoint(playerid);
    if(PInfo[playerid][CanBurst] == 0) PInfo[playerid][CanBurst] = 1, KillTimer(PInfo[playerid][ClearBurst]);
    SnowCreated[playerid] = 0;

 	if(RoundEnded == 0)
 	{
		INI_Open("Admin/Teams.txt");
		INI_WriteInt(GetPName(playerid),Team[playerid]);
		INI_Save();
		INI_Close();
 	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	new
		joinMsg[128],
		name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	format(joinMsg, sizeof(joinMsg), "02[%d] 03*** %s entrу al servidor.", playerid, name);
	IRC_GroupSay(gGroupID, IRC_CHANNEL, joinMsg);

	new connecting_ip[32+1];
	GetPlayerIp(playerid,connecting_ip,32);
	new num_players_on_ip = GetNumberOfPlayersOnThisIP(connecting_ip);

	if(num_players_on_ip > MAX_CONNECTIONS_FROM_IP)
	{
		printf("MAXIPs: Connecting player(%d) exceeded %d IP connections from %s.", playerid, MAX_CONNECTIONS_FROM_IP, connecting_ip);
	    Kick(playerid);
	}

    if(IsPlayerNPC(playerid))
  	{
	  	new npcname[MAX_PLAYER_NAME];
	  	GetPlayerName(playerid, npcname, sizeof(npcname));
	  	if(!strcmp(npcname, "Sgt_Soap", true))
    	{
    	    SetPlayerColor(playerid, 0x5E610BFF);
	      	PutPlayerInVehicle(playerid, NPCVehicle2, 0);
	      	SpawnPlayer(playerid);
      	}
      	if(!strcmp(npcname, "Sgt_Nikolai", true))
    	{
    	    SetPlayerColor(playerid, 0x5E610BFF);
	      	PutPlayerInVehicle(playerid, NPCVehicle3, 0);
	      	SpawnPlayer(playerid);
      	}
  		return 1;
  	}

	PlaySound(playerid,1077);
    PlayersConnected++;

    Streaks[playerid] = 0;
    CanHide{playerid} = true;
	PInfo[playerid][P_STATUS] = PS_CONNECTED;
	CBugTimes[playerid] = 0;
	SetPlayerWeather(playerid, 9);
	SetPlayerTime(playerid, 6, 0);
	PlayerState[playerid] = false;
	PInfo[playerid][SPerk] = 1;
	PInfo[playerid][ZPerk] = 1;
	PInfo[playerid][Bites] = 0;
	PInfo[playerid][Rank] = 1;
	PInfo[playerid][SSkin] = 0;
	PInfo[playerid][ZSkin] = 0;
    PInfo[playerid][XP] = 0;
    PInfo[playerid][Level] = 0;
    PInfo[playerid][Premium] = 0;
    PInfo[playerid][Kills] = 0;
    PInfo[playerid][Infects] = 0;
    PInfo[playerid][Deaths] = 0;
    PInfo[playerid][Teamkills] = 0;
    PInfo[playerid][CPCleared] = 0;
    PInfo[playerid][Assists] = 0;
    PInfo[playerid][XPToRankUp] = 50;
    PInfo[playerid][Assists] = 0;
    PInfo[playerid][Vomited] = 0;
	PInfo[playerid][Logged] = 0;
	PInfo[playerid][Failedlogins] = 0;
	PInfo[playerid][CanBite] = 1;
	PInfo[playerid][JustInfected] = 0;
	PInfo[playerid][Infected] = 0;
	PInfo[playerid][Dead] = 1;
	PInfo[playerid][Firsttimeincp] = 1;
	PInfo[playerid][CanBurst] = 1;
	PInfo[playerid][Firstspawn] = 1;
 	PInfo[playerid][ZombieBait] = 0;
	PInfo[playerid][FireMode] = 0;
	PInfo[playerid][OnFire] = 0;
	PInfo[playerid][TokeDizzy] = 0;
	PInfo[playerid][CanJump] = 8000;
	PInfo[playerid][LuckyCharm] = 60000;
	PInfo[playerid][CanPop] = 1;
	PInfo[playerid][CanStomp] = 1;
	PInfo[playerid][CanRun] = 1;
    PInfo[playerid][Flamerounds] = 0;
    PInfo[playerid][MolotovMission] = 0;
    PInfo[playerid][BettyMission] = 0;
    PInfo[playerid][CanDig] = 1;
    PInfo[playerid][GodDig] = 0;
    PInfo[playerid][Vomitmsg] = 1;
    PInfo[playerid][Lighton] = 0;
    PInfo[playerid][NoPM] = 0;
    PInfo[playerid][LastID] = -1;
    PInfo[playerid][Allowedtovomit] = VOMITTIME;
    PInfo[playerid][oslotglasses] = -1;
    Mission[playerid] = 0;
    MissionPlace[playerid][0] = 0;
    MissionPlace[playerid][1] = 0;
    CurrentObject{playerid} = 0xFFFF;
    Activated{playerid} = false;
    RemovePlayerMapIcon(playerid,1);
	/*new label[64];
	format(label,sizeof label,""cgreen"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]);
 	PInfo[playerid][Ranklabel] = CreateDynamic3DTextLabel(label,0x85C051FF, 0.0, 0.0, 0.30, 5.0, playerid);*/

 	new file[64];
 	format(file,sizeof file,""cgreen"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]);
 	PInfo[playerid][Ranklabel] = Create3DTextLabel(file, 0x008080AA, 0, 0, 0, 30.0, 0);
	Attach3DTextLabelToPlayer(PInfo[playerid][Ranklabel], playerid, 0.0, 0.0, 0.3);

	XPBox[playerid][0] = CreatePlayerTextDraw(playerid, 100.625000, 439.083435, "_");
	PlayerTextDrawLetterSize(playerid, XPBox[playerid][0], 0.398748, 0.456667);
	PlayerTextDrawTextSize(playerid, XPBox[playerid][0], 541.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, XPBox[playerid][0], 1);
	PlayerTextDrawColor(playerid, XPBox[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, XPBox[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, XPBox[playerid][0], 170);
	PlayerTextDrawSetShadow(playerid, XPBox[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, XPBox[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, XPBox[playerid][0], 255);
	PlayerTextDrawFont(playerid, XPBox[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, XPBox[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, XPBox[playerid][0], 0);

	XPBox[playerid][1] = CreatePlayerTextDraw(playerid, 100.625000, 439.083435, "_");
	PlayerTextDrawLetterSize(playerid, XPBox[playerid][1], 0.398748, 0.456667);
	PlayerTextDrawTextSize(playerid, XPBox[playerid][1], 541.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, XPBox[playerid][1], 1);
	PlayerTextDrawColor(playerid, XPBox[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, XPBox[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, XPBox[playerid][1], 0x9BD6FFFF);
	PlayerTextDrawSetShadow(playerid, XPBox[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, XPBox[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, XPBox[playerid][1], 255);
	PlayerTextDrawFont(playerid, XPBox[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, XPBox[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, XPBox[playerid][1], 0);

	XPStats[playerid] = CreatePlayerTextDraw(playerid, 299.375000, 436.750000, "XP:_0/50");
	PlayerTextDrawLetterSize(playerid, XPStats[playerid], 0.254999, 0.847499);
	PlayerTextDrawAlignment(playerid, XPStats[playerid], 1);
	PlayerTextDrawColor(playerid, XPStats[playerid], -106);
	PlayerTextDrawSetShadow(playerid, XPStats[playerid], 0);
	PlayerTextDrawSetOutline(playerid, XPStats[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, XPStats[playerid], 255);
	PlayerTextDrawFont(playerid, XPStats[playerid], 1);
	PlayerTextDrawSetProportional(playerid, XPStats[playerid], 1);
	PlayerTextDrawSetShadow(playerid, XPStats[playerid], 0);

	StatsBoxDraw[playerid] = CreatePlayerTextDraw(playerid, 547.749877, 369.057647, "Rank:_1~n~Kills:_0~n~TeamKills:_0~n~Deaths:_0~n~Perk:_1~n~CPs_Cleared:_0~n~Achievements:_Soon");
	PlayerTextDrawLetterSize(playerid, StatsBoxDraw[playerid], 0.182499, 0.888332);
	PlayerTextDrawAlignment(playerid, StatsBoxDraw[playerid], 1);
	PlayerTextDrawColor(playerid, StatsBoxDraw[playerid], -1);
	PlayerTextDrawSetShadow(playerid, StatsBoxDraw[playerid], 0);
	PlayerTextDrawSetOutline(playerid, StatsBoxDraw[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, StatsBoxDraw[playerid], 255);
	PlayerTextDrawFont(playerid, StatsBoxDraw[playerid], 2);
	PlayerTextDrawSetProportional(playerid, StatsBoxDraw[playerid], 1);
	PlayerTextDrawSetShadow(playerid, StatsBoxDraw[playerid], 0);

	PTD_INTRO_PLAY[playerid][0] = CreatePlayerTextDraw(playerid, 190.000000, 152.051834, "");
	PlayerTextDrawLetterSize(playerid, PTD_INTRO_PLAY[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PTD_INTRO_PLAY[playerid][0], 103.000000, 110.000000);
	PlayerTextDrawAlignment(playerid, PTD_INTRO_PLAY[playerid][0], 1);
	PlayerTextDrawColor(playerid, PTD_INTRO_PLAY[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, PTD_INTRO_PLAY[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, PTD_INTRO_PLAY[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, PTD_INTRO_PLAY[playerid][0], 8947840);
	PlayerTextDrawFont(playerid, PTD_INTRO_PLAY[playerid][0], 5);
	PlayerTextDrawSetProportional(playerid, PTD_INTRO_PLAY[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, PTD_INTRO_PLAY[playerid][0], 0);
	PlayerTextDrawSetPreviewModel(playerid, PTD_INTRO_PLAY[playerid][0], 67);
	PlayerTextDrawSetPreviewRot(playerid, PTD_INTRO_PLAY[playerid][0], 0.000000, 0.000000, 15.000000, 1.000000);

	PTD_INTRO_PLAY[playerid][1] = CreatePlayerTextDraw(playerid, 347.000000, 152.051834, "");
	PlayerTextDrawLetterSize(playerid, PTD_INTRO_PLAY[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, PTD_INTRO_PLAY[playerid][1], 103.000000, 110.000000);
	PlayerTextDrawAlignment(playerid, PTD_INTRO_PLAY[playerid][1], 1);
	PlayerTextDrawColor(playerid, PTD_INTRO_PLAY[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, PTD_INTRO_PLAY[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, PTD_INTRO_PLAY[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, PTD_INTRO_PLAY[playerid][1], 8947840);
	PlayerTextDrawFont(playerid, PTD_INTRO_PLAY[playerid][1], 5);
	PlayerTextDrawSetProportional(playerid, PTD_INTRO_PLAY[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, PTD_INTRO_PLAY[playerid][1], 0);
	PlayerTextDrawSetPreviewModel(playerid, PTD_INTRO_PLAY[playerid][1], 67);
	PlayerTextDrawSetPreviewRot(playerid, PTD_INTRO_PLAY[playerid][1], 0.000000, 0.000000, 345.000000, 1.000000);

	PTD_INTRO_GUIDE[playerid] = CreatePlayerTextDraw(playerid, 175.000000, 162.000000,
	"The_objective_of_the_humans_team_is_to_complete_all_the_8~n~checkpoints_scattered_around_the_map.\
	~n~~n~Staying_in_higher_placer_will_increase_your_chances_of_surviving.~n~Join_forces_with_your_team_to_win.~n~\
	Make_a_good_use_of_your_ammor.~n~Each_level_has_an_ability.~n~Press_Y_to_change_your_perk_and_N_to_open_your_inventory.~n~~n~\
	You_can_search_for_items_inside_interiors_by_pressing_C_key.~n~In_order_to_win,_the_humans_team_has_to_complete_all_the~n~checkpoints_around_the_map.~n~~n~");
	PlayerTextDrawLetterSize(playerid, PTD_INTRO_GUIDE[playerid], 0.257333, 1.181035);
	PlayerTextDrawAlignment(playerid, PTD_INTRO_GUIDE[playerid], 1);
	PlayerTextDrawColor(playerid, PTD_INTRO_GUIDE[playerid], -187);
	PlayerTextDrawSetShadow(playerid, PTD_INTRO_GUIDE[playerid], 0);
	PlayerTextDrawSetOutline(playerid, PTD_INTRO_GUIDE[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, PTD_INTRO_GUIDE[playerid], 16750847);
	PlayerTextDrawFont(playerid, PTD_INTRO_GUIDE[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PTD_INTRO_GUIDE[playerid], 1);
	PlayerTextDrawSetShadow(playerid, PTD_INTRO_GUIDE[playerid], 0);

/*	for(new i; i < MAX_PLAYERS;i++)
	{
	    SetPlayerMarkerForPlayer(i, playerid, 0x969696FF);
	}*/
	INI_Open("Admin/Teams.txt");
    if(INI_ReadInt(GetPName(playerid)) != 0)
    {
        PInfo[playerid][Firstspawn] = 0;
		Team[playerid] = INI_ReadInt(GetPName(playerid));
		printf("%i",Team[playerid]);
    }
    INI_Close();

	PlayAudioStreamForPlayer(playerid, ZombieMusic[ random(sizeof ZombieMusic) ] );
    SendClientMessage(playerid, white, "» "cgold"Loading server data ...");
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(PInfo[playerid][Firsttimeincp] == 1)
    {
        if(Team[playerid] == ZOMBIE) return 0;

		new Float:x,Float:y,Float:z;
		GetPlayerPos(playerid,x,y,z);
        for(new i; i < MAX_PLAYERS;i++)
        {
            if(!IsPlayerConnected(i)) continue;
            if(!IsPlayerInRangeOfPoint(i,25.0,x,y,z)) continue;
            SendFMessage(i,white,"*"cjam"%s has been assisted with military help.",GetPName(playerid));
        }
    	PInfo[playerid][Firsttimeincp] = 0;
        new weapons[13][2];
		for(new f = 0; f < 13; f++)
		{
		    GetPlayerWeaponData(playerid, f, weapons[f][0], weapons[f][1]);
		}
		if(PInfo[playerid][SPerk] == 17)
		{
			PInfo[playerid][Flamerounds] += 3;
			SendFMessage(playerid,white,"» "cblue"You have been given 3 flame bullets. "cgrey"(%i flame bullets)",PInfo[playerid][Flamerounds]);
		}
		if(PInfo[playerid][SPerk] == 4)
		{
		    GivePlayerWeapon(playerid,17,1);
		    if(PInfo[playerid][Premium] == 1)
		        GivePlayerWeapon(playerid,17,2);
            if(PInfo[playerid][Premium] == 2)
		        GivePlayerWeapon(playerid,17,4);
		}

		if(PInfo[playerid][SPerk] == 19) GivePlayerWeapon(playerid,16,3);
		if(weapons[2][0] == 22) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,22,20);}else{GivePlayerWeapon(playerid,22,50); }
		if(weapons[2][0] == 23) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,23,20);}else{GivePlayerWeapon(playerid,23,50); }
		if(weapons[2][0] == 24) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,24,20);}else{GivePlayerWeapon(playerid,24,50); }
		if(weapons[3][0] == 25) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,25,30);}else{GivePlayerWeapon(playerid,25,20); }
		if(weapons[3][0] == 26) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,26,30);}else{GivePlayerWeapon(playerid,26,30); }
		if(weapons[3][0] == 27) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,27,30);}else{GivePlayerWeapon(playerid,27,30); }
		if(weapons[4][0] == 28) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,28,120);}else{GivePlayerWeapon(playerid,28,120); }
		if(weapons[4][0] == 32) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,32,120);}else{GivePlayerWeapon(playerid,32,120); }
		if(weapons[6][0] == 33) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,33,30);}else{GivePlayerWeapon(playerid,33,30); }

		if(IsPlayerInAnyVehicle(playerid)) SetPlayerArmedWeapon(playerid,0);

        if(PInfo[playerid][Premium] == 2)
	    {
	        SetPlayerArmour(playerid,150);
	        for(new i; i < MAX_PLAYERS;i++)
	        {
	            if(!IsPlayerConnected(i)) continue;
	            if(!IsPlayerInRangeOfPoint(i,25.0,x,y,z)) continue;
	            SendFMessage(i,white,"*"cjam"%s has been given a fresh new kevlar vest.",GetPName(playerid));
	        }
     	}
     	if(PInfo[playerid][Premium] == 1)
	    {
	        SetPlayerArmour(playerid,100);
	        for(new i; i < MAX_PLAYERS;i++)
	        {
	            if(!IsPlayerConnected(i)) continue;
	            if(!IsPlayerInRangeOfPoint(i,25.0,x,y,z)) continue;
	            SendFMessage(i,white,"*"cjam"%s has been given a fresh new kevlar vest.",GetPName(playerid));
	        }
     	}
  	}
    return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	if(Team[playerid] == ZOMBIE) return 1;
	if(HasLeftCP{playerid} == false) {
	    HasLeftCP{playerid} = true;
	    SendClientMessage(playerid, white,"WARNING: "cred"You have left the checkpoint. "cwhite"***");
	    SendClientMessage(playerid, white,"TIP: "cred"You won't get XP and your health doesn't increase if you left the checkpoint. "cwhite"***");
	}
    return 1;
}

public OnRconLoginAttempt(ip[], password[], success) // ANTI-FAILED-RCON-LOGIN: Help By SA:MP Wiki
{
    if(!success)
    {
        printf("RCON Wrong Password. IP: %s. Password: %s",ip, password);
        new pla[16];
        for(new i=0; i<MAX_PLAYERS; i++)
        {
            GetPlayerIp(i, pla, sizeof(pla));
            if(!strcmp(ip, pla, true))
            {
                SendClientMessage(i, 0xFF4500AA, "[Anti-RconHack]: Failed RCON Login!");
                ShowPlayerDialog(i, Rconerrordialog, DIALOG_STYLE_MSGBOX, "You Have Been Kicked!", "{FFFFFF}You've been {FF0000}kicked{FFFFFF}!\nReason: Failed RCON Login!", "OK", "OK");
                KickEx(i);
            }
        }
    }
    return 1;
}

CMD:anims(playerid, params[])
{
    new string[1024];
    strcat(string, "{9F9F9F}" "/relax | /scared | /sick | /wave | /spank | /taichi | /crossarms |\n", 1024);
    strcat(string, "{FFA200}" "/wank | /kiss | /talk | /fucku | /cocaine | /rocky | /sit | /smoke |\n", 1024);
    strcat(string, "{9F9F9F}" "/beach | /lookout | /circle | /medic | /chat | /die | /slapa | /rofl |\n", 1024);
    strcat(string, "{FFA200}" "/glitched | /fakefire | /bomb | /robman | /handsup | /piss |\n", 1024);
    strcat(string, "{9F9F9F}" "/getin | /skate | /cover | /vomit | /drunk |\n", 1024);
    strcat(string, "{FFA200}" "/funnywalk | /kickass | /cell | /laugh | /eat | /injured |\n", 1024);
    strcat(string, "{9F9F9F}" "/slapass | /laydown | /arrest | /carjack |\n", 1024);
    strcat(string, ""cgreen"Type /animsoff to stop the animation.", 1024);
    ShowPlayerDialog(playerid,DIALOG_ANIMS,DIALOG_STYLE_MSGBOX,"{9F9F9F}" "DAnims", string, "-->oK<--", "");
    return 1;
}

////////////////////////////////////////////////////////////////////////////////
CMD:handsup(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:bomb(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:robman(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:crossarms(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"PAULNMAC", "wank_loop", 1.800001, 1, 0, 0, 1, 600);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:taichi(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:spank(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:wave(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:sick(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:scared(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid, "ped", "cower", 3.0, 1, 0, 0, 0, 0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:talk(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"PED","IDLE_CHAT",1.800001, 1, 1, 1, 1, 13000);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:kiss(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"KISSING", "Grlfrd_Kiss_02", 1.800001, 1, 0, 0, 1, 600);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:sit(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"INT_OFFICE", "OFF_Sit_Bored_Loop", 1.800001, 1, 0, 0, 1, 600);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:fucku(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"ped", "fucku", 4.1, 0, 1, 1, 1, 1 );
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:cocaine(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"CRACK", "crckdeth2", 1.800001, 1, 0, 0, 1, 600);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:rocky(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"GYMNASIUM", "GYMshadowbox", 1.800001, 1, 0, 0, 1, 600);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:smoke(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"SMOKING", "M_smklean_loop", 4.0, 1, 0, 0, 0, 0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:beach(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"BEACH","SitnWait_loop_W",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:lookout(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"ON_LOOKERS","lkup_in",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:circle(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"CHAINSAW","CSAW_Hit_2",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:medic(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"MEDIC","CPR",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:chat(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"PED","IDLE_CHAT",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:die(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"PED","BIKE_fallR",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:slapa(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"PED","BIKE_elbowL",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:rofl(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"PED","Crouch_Roll_L",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:glitched(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"TATTOOS","TAT_Sit_Out_O",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:fakefire(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"SILENCED","SilenceCrouchfire",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:vomit(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
    	ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);
    	PlayerPlaySound(playerid, 1169, 0.0, 0.0, 0.0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:drunk(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
	    ApplyAnimation(playerid,"PED","WALK_DRUNK",4.1,0,1,1,1,1);
	    ApplyAnimation(playerid,"PED","WALK_DRUNK",4.1,0,1,1,1,1);
	    ApplyAnimation(playerid,"PED","WALK_DRUNK",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:getin(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"NEVADA","NEVADA_getin",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:piss(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
    	SetPlayerSpecialAction(playerid, 68);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:funnywalk(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid,"WUZI","Wuzi_Walk",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:kickass(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
    	ApplyAnimation(playerid,"FIGHT_E","Hit_fightkick",4.1,0,1,1,1,1);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:cell(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
    	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:laugh(playerid, params[])
{
    if (GetPlayerState(playerid)== 1)
    {
        ApplyAnimation(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0);
    }
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:eat(playerid, params[])
{
    ApplyAnimation(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:injured(playerid, params[])
{
    ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:slapass(playerid, params[])
{
    ApplyAnimation(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0);
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:laydown(playerid, params[])
{
    ApplyAnimation(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:arrest(playerid, params[])
{
    ApplyAnimation(playerid,"ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1);
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:carjack(playerid, params[])
{
    ApplyAnimation(playerid,"PED","CAR_jackedLHS",4.0,0,1,1,1,0);
    return 1;
}
////////////////////////////////////////////////////////////////////////////////
CMD:animsoff(playerid, params[])
{
    ClearAnimations(playerid);
    return 1;
}

CMD:gotopumpkin(playerid, params[])
{
	if(PInfo[playerid][Level] < 4) return SendClientMessage(playerid, white, "* "cred"You have to be administrator to use this command.");
	if(PumpkinOn == 0) return SendClientMessage(playerid, -1, "Pumpkin isn't spawned.");
	if(Winner == 1) return SendClientMessage(playerid, -1, "There is no pumpkin spawn.");
	if(GetPlayerState(playerid) == 2) SetVehiclePos(GetPlayerVehicleID(playerid), RandomPositions[Number][0], RandomPositions[Number][1]+5, RandomPositions[Number][2]);
	else SetPlayerPos(playerid, RandomPositions[Number][0], RandomPositions[Number][1]+5, RandomPositions[Number][2]);
	SendClientMessage(playerid, -1, "You've been teleported near the pumpkin.");
	return 1;
}

CMD:aod(playerid, params[])
{
	if(PInfo[playerid][Level] >=1 || IsPlayerAdmin(playerid))
	{
		if (aDuty{playerid} == false)
		{
			GetPlayerHealth(playerid, DutyHealth[playerid]);
			SendFMessageToAll(white, "[AOD] "cred"%s is now on Duty!", GetPName(playerid));
			SendClientMessage(playerid, white, "* "cred"You are now on duty!");
			SetPlayerHealth(playerid, 100);
			AODSkin[playerid] = GetPlayerSkin(playerid);
			SetPlayerColor(playerid, red);
			SetPlayerSkin(playerid, 217);
			aDuty{playerid} = true;
		}
		else if (aDuty{playerid} == true)
		{
     		SetPlayerHealth(playerid, DutyHealth[playerid]);
			SendFMessageToAll(white, "[AOD] "cred"%s is now off Duty!", GetPName(playerid));
			SendClientMessage(playerid, white, "* "cred"You are now off duty!");
			SetPlayerSkin(playerid, AODSkin[playerid]);
			if(Team[playerid] == HUMAN)
			    SetPlayerColor(playerid, green);
			else
			    SetPlayerColor(playerid, purple);

			aDuty{playerid} = false;
		}
 	}
	else
		SendClientMessage(playerid, white, "* "cred"You have to be administrator to use this command.");
	return 1;
}

CMD:makeleader(playerid, params[])
{
	new str[128];
    if(PInfo[playerid][Level] < 4) return SendClientMessage(playerid, white, "* "cred"You have to be high administrator to use this command.");
	if(sscanf(params, "ud", params[0], params[1])) return SendClientMessage(playerid, white, "USE: /makeleader [ID] [Clan ID]");
	if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, white, "ERROR: Wrong ID");
	SendFMessage(params[0], white, "|| "cred"Administrator %s has given you Clan Leader of the clan ID: %d "cwhite"||", GetPName(playerid), params[1]);
	format(str, sizeof(str), "|| Administrator %s has made to %s clan leader. ClanID: %d ||", GetPName(playerid), GetPName(params[0]), params[1]);
	SendAdminMessage(red, str);

    PInfo[params[0]][ClanLeaderID] = params[1];
    PInfo[params[0]][ClanID] = params[1];

	SaveStats(params[0]);
	return 1;
}

CMD:commands(playerid, params[])
{
    SendClientMessage(playerid, 0x33DA00FF, "* Commands *");
    SendClientMessage(playerid, 0x33DA00FF, "* Chat commands: "cwhite"/me - /l");
    SendClientMessage(playerid, 0x33DA00FF, "* Have you got a clan? "cwhite"Type /clanhelp to view the clan information.");
    SendClientMessage(playerid, 0x33DA00FF, "* Are you premium and you want to know the commands? "cwhite"Check it out using /premiumhelp");
    SendClientMessage(playerid, 0x33DA00FF, "* Animations: "cwhite"/anims - /animsoff");
    return 1;
}

CMD:clanhelp(playerid, params[])
{
    if(PInfo[playerid][ClanLeaderID] == 0)
    {
		SendClientMessage(playerid, 0x33DA00FF, "* Clan Help *");
		SendClientMessage(playerid, 0x33DA00FF, "To talk with your clan mates, you can use /c [TEXT]");
	} else {
	    SendClientMessage(playerid, 0x33DA00FF, "* Clan Help *");
		SendClientMessage(playerid, 0x33DA00FF, "To talk with your clan mates, you can use /c [TEXT]");
		SendClientMessage(playerid, 0x33DA00FF, "As leader you can add or remove members of your clan with: /addmember [PlayerID] or /removemember [PlayerID]");
		SendClientMessage(playerid, 0x33DA00FF, "The player to be added or removed have to be online in game.");
	}
	return 1;
}

CMD:addmember(playerid, params[])
{
    if(PInfo[playerid][ClanLeaderID] < 1) return SendClientMessage(playerid, white, "* "cred"You have to be a clan leader to use this command.");
    if(sscanf(params, "u", params[0])) return SendClientMessage(playerid, white, "USE: /addmember [ID]");
	if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, white, "ERROR: Wrong ID");
    if(PInfo[params[0]][ClanID] != 0) return SendClientMessage(playerid, white, "That player is already in a clan.");
	PInfo[params[0]][ClanID] = PInfo[playerid][ClanLeaderID];
	SendFMessage(playerid, white, "* "cgreen"You added a member to your clan sucessfully. (You added to: %s to your clan as member)", GetPName(params[0]));
    SendFMessage(params[0], white, "|| "cred"Leader %s has added you as member of the clan ID: %d "cwhite"||", GetPName(playerid), params[1]);
    SaveStats(params[0]);
    SaveClanStats(PInfo[playerid][ClanLeaderID]);
	return 1;
}

CMD:removemember(playerid, params[])
{
    if(PInfo[playerid][ClanLeaderID] < 1) return SendClientMessage(playerid, white, "* "cred"You have to be a clan leader to use this command.");
    if(sscanf(params, "u", params[0])) return SendClientMessage(playerid, white, "USE: /removemember [ID]");
	if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, white, "ERROR: Wrong ID");
    if(PInfo[params[0]][ClanID] < 1) return SendClientMessage(playerid, white, "That player isn't in a clan.");
    if(PInfo[playerid][ClanLeaderID] != PInfo[params[0]][ClanID]) return SendClientMessage(playerid, white, "That player isn't in your clan.");
	PInfo[params[0]][ClanID] = 0;
	SendFMessage(playerid, white, "* "cgreen"You removed a member from your clan sucessfully. (You removed to: %s)", GetPName(params[0]));
    SendFMessage(params[0], white, "|| "cred"Leader %s has added you as member of the clan ID: %d "cwhite"||", GetPName(playerid), params[1]);
    SaveStats(params[0]);
    SaveClanStats(PInfo[playerid][ClanLeaderID]);
	return 1;
}

CMD:airdrop(playerid, params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid, white, "* "cred"You have to be high administrator to use this command.");
	if(AirDroppedItem{airdropitem} == true) return 1;
	new Float:NPCPos[3];
	GetVehiclePos(NPCVehicle3, NPCPos[0], NPCPos[1], NPCPos[2]);

    DestroyObject(airdropitem);
    airdropitem = CreateObject(18849, NPCPos[0], NPCPos[1], NPCPos[2], 0.0, 0.0, 90.0);

    MoveObject(airdropitem, NPCPos[0], NPCPos[1], NPCPos[2]+0.8, 5.80);
    CA_FindGroundZ(NPCPos[0], NPCPos[1], NPCPos[2], caZAirdrop);

    AirDroppedItem{airdropitem} = true;

	SetTimerEx("MoveAirItem", 200, false, "ffff", NPCPos[0], NPCPos[1], caZAirdrop+7.3, -0.01);

    SendClientMessageToAll(white, "** {009CBB}RADIO: AirDrop "cwhite"!");
	SendClientMessageToAll(white, "» LOCUTOR: {5CA488}Sgt Nikolei has thrown a bag with subministers.");
	SendClientMessageToAll(white, "» LOCUTOR: {5CA488}Find that bag to get items.");

	new rand = random(3);
	if(rand == 0) AirDTimer = SetTimer("AirDropTimer", 900000, true);
	else if(rand == 1) AirDTimer = SetTimer("AirDropTimer", 600000, true);
	else if(rand == 2) AirDTimer = SetTimer("AirDropTimer", 720000, true);
	return 1;
}

CMD:goairdrop(playerid, params[])
{
	if(!IsPlayerAdmin(playerid) || PInfo[playerid][Level] < 5) return SendClientMessage(playerid, white, "* "cred"You have to be high administrator to use this command.");
	new Float:obPos[3];
	GetObjectPos(airdropitem, obPos[0], obPos[1], obPos[2]);
	SetPlayerPos(playerid, obPos[0], obPos[1], obPos[2]);
	return 1;
}

CMD:createclan(playerid, params[])
{
	new cname[24];
	if(sscanf(params, "s[24]", cname)) return SendClientMessage(playerid, -1, "USAGE: /createclan <clan_name>");
	format(DB_Query, sizeof DB_Query, "INSERT INTO CLANS (NAME) VALUES ('%s')", cname);
	db_query(Database, DB_Query);
	return 1;
}

CMD:ptop(playerid,params[])
{
	new rank_info[200], player_name[MAX_PLAYER_NAME], DBResult: result = db_query(Database, "SELECT `NAME`,`RANK`,`KILLS`,`INFECTS`,`DEATHS` FROM `USERS` ORDER BY `RANK` DESC limit 10");
	new var[1500];
	for (new a, rows = db_num_rows(result); a < rows; a++)
	{
	    db_get_field(result, 0, player_name, sizeof player_name);
	    format(rank_info, sizeof(rank_info), ""cred"%d. "cwhite"%s - "cgreen"Rank: "cwhite"%d - "cgreen"Kills: "cwhite"%d - "cgreen"Infects: "cwhite"%d - "cgreen"Deaths: "cwhite"%d\n", a + 1, player_name, db_get_field_int(result, 1), db_get_field_int(result, 2), db_get_field_int(result, 3), db_get_field_int(result, 4));
	    strcat(var, rank_info);
	    db_next_row(result);
	}
	db_free_result(result);
	ShowPlayerDialog(playerid, Topplayerdialog, DIALOG_STYLE_MSGBOX, ""cwhite"Top 10 Players", var, "[ V ]", "[ x ]");
	return 1;
}

CMD:ctop(playerid,params[])
{
	new rank_info[200], clan_name[MAX_PLAYER_NAME], DBResult: result = db_query(Database, "SELECT `NAME`,`XP`,`KILLS`,`INFECTS` FROM `CLANS` ORDER BY `XP` DESC limit 10");
	new var[1500];
	for (new a, rows = db_num_rows(result); a < rows; a++)
	{
	    db_get_field(result, 0, clan_name, sizeof clan_name);
	    format(rank_info, sizeof(rank_info), ""cred"%d. "cwhite"%s - "cgreen"XP: "cwhite"%d - "cgreen"KILLS: "cwhite"%d - "cgreen"INFECTS: "cwhite"%d\n", a + 1, clan_name, db_get_field_int(result, 1), db_get_field_int(result, 2),db_get_field_int(result, 3));
	    strcat(var, rank_info);
	    db_next_row(result);
	}
	db_free_result(result);
	ShowPlayerDialog(playerid, Topplayerdialog, DIALOG_STYLE_MSGBOX, ""cwhite"Top 10 Clans", var, "[ V ]", "[ x ]");
	return 1;
}

CMD:rangeban(playerid, params[])
{
    new Target;
    new Reason[100];
    if(PInfo[playerid][Level] < 4) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
    if(!sscanf(params, "us[128]", Target,Reason))
    {
    	if(Target == INVALID_PLAYER_ID) return SendClientMessage(playerid,-1,"ERROR: Wrong player ID");
    	if(Target == playerid) return SendClientMessage(playerid,-1,"ERROR: You cant ban yourself!");
		new tname[MAX_PLAYER_NAME];
		GetPlayerName(Target,tname,sizeof(tname));
		new pname[MAX_PLAYER_NAME];
		GetPlayerName(playerid,pname,sizeof(pname));
		new MyString[256];
		new TargetString[256];
		new rbandate[3];
		getdate(rbandate[0], rbandate[1], rbandate[2]);
		format(MyString,sizeof(MyString),"You have range banned %s(%d)! (Reason: %s)",tname, Target, Reason);
		format(TargetString,sizeof(TargetString),"{FF002B}Range banned by: {FFFFFF}%s\n\n{FF002B}Reason: {FFFFFF}%s\n\n{FF002B}Date: {FFFFFF}%02d/%02d/%04d\n\n{FFFFFF}Press F8 to take a screenshot and use this in unban appeal!", pname, Reason, rbandate[2], rbandate[1], rbandate[0]);
		ShowPlayerDialog(Target, Ragebandialog, DIALOG_STYLE_MSGBOX, "{FF002B}RANGE BANNED!", TargetString, "OK", "");
		SendClientMessage(playerid, red,MyString);
		new AllString[256];
		format(AllString,sizeof(AllString),"|| Administrator %s range banned player %s(%d)! (Reason: %s) ||",pname,tname,Target,Reason);
		SendClientMessageToAll(red,AllString);
		new ip[50];
		GetPlayerIp(Target,ip,sizeof(ip));
		strdel(ip,strlen(ip)-4,strlen(ip));
		format(ip,sizeof(ip),"%s**.**",ip);
		format(ip,sizeof(ip),"banip %s",ip);
    	SendRconCommand(ip);
    	KickEx(Target);
	}
    else SendClientMessage(playerid, -1, "USAGE: /rangeban <playerid> <reason>");
    return 1;
}

CMD:hide(playerid, params[])
{
	if(Team[playerid] != ZOMBIE) return SendClientMessage(playerid,red,"You have to be zombie to use this command.");
	if(PInfo[playerid][ZPerk] != 5) return SendClientMessage(playerid,red,"You must active th perk 'Hide Mode'.");
	if(CanHide{playerid} == false) return SendClientMessage(playerid,red,"Wait three minuts before using /hide again.");
	if(IsHide[playerid] != 1)
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_PASSENGER) return SendClientMessage(playerid,red,"You must sit as passenger to /hide.");
		IsHide[playerid] = 1;
		PSit[playerid] = GetPlayerVehicleSeat(playerid);
		Vhid[playerid] = GetPlayerVehicleID(playerid);
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectateVehicle(playerid,Vhid[playerid]);
		SendClientMessage(playerid, white,"* "cgreen"You are now hidden. - Type /hide to make you visible -");
		new string[100];
	    format(string,sizeof string,""cjam"%s has hidden inside the vehicle.",GetPName(playerid));
		SendNearMessage(playerid,white,string,20);
		SetPVarInt(playerid,"PISVisible",0);
	}
	else
	{
	    SetPVarInt(playerid,"PISVisible",1);
		IsHide[playerid] = 0;
		TogglePlayerSpectating(playerid, 0);
		PutPlayerInVehicle(playerid, Vhid[playerid], PSit[playerid]);
		PSit[playerid] = -1;
		Vhid[playerid] = -1;
		CanHide{playerid} = false;
		SendClientMessage(playerid, white,"* "cgreen"You are now visible. - Now you have to wait three minuts before using this perk again -");
		SetTimerEx("ZHideAgain", 180000, 0, "i", playerid);
	}
	return 1;
}

CMD:premiumhelp(playerid, params[])
{
	if(PInfo[playerid][Premium] > 0) {
	    SendClientMessage(playerid, green, ""cgold"Premium commands:");
	    SendClientMessage(playerid, white, "/setsskin - /setzskin - /setperk - /c to chat your clan mates");
	} else {
	    SendClientMessage(playerid, green, "> PREMIUM HELP <");
	    SendClientMessage(playerid, white, "Here we have our premium packs for you!");
	    SendClientMessage(playerid, white, ""cgold"Gold: "cwhite"5$ | "cplat"Platinum: "cwhite"10$");
	    SendClientMessage(playerid, white, "Go to our forums to get more info: www.eternal-games.net");
	}
	return 1;
}

CMD:cc(playerid, params[])
{
    if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    SendClientMessageToAll(-1, " ");
    new str[68];
    format(str, sizeof str, "|| Chat cleared by the administrator %s ||", GetPName(playerid));
    SendClientMessageToAll(red, str);
	return 1;
}

CMD:setint(playerid, params[])
{
    if(PInfo[playerid][Level] < 2) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(sscanf(params, "ud", params[0], params[1])) return SendClientMessage(playerid, Grey, "USAGE: /setint <id> <interior id>");
	if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, red, "That player is not connected!");
	new msg[128];
	format(msg, sizeof msg, "|| "cred"Administrator %s has setted %s's Interior ID to %d "cwhite"||", GetPName(playerid), GetPName(params[0]), params[1]);
	SendAdminMessage(white, msg);
	format(msg, sizeof msg, "|| "cred"Administrator %s has setted your Interior ID to %d "cwhite"||", GetPName(playerid), params[1]);
	SendClientMessage(params[0], white, msg);
	SetPlayerInterior(params[0], params[1]);
	return 1;
}

CMD:setvw(playerid, params[])
{
    if(PInfo[playerid][Level] < 2) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(sscanf(params, "ud", params[0], params[1])) return SendClientMessage(playerid, Grey, "USAGE: /setvw <id> <virtual world id>");
	if(!IsPlayerConnected(params[0])) return SendClientMessage(playerid, red, "That player is not connected!");
	new msg[128];
	format(msg, sizeof msg, "|| "cred"Administrator %s has setted %s's VirtualWorld ID to %d "cwhite"||", GetPName(playerid), GetPName(params[0]), params[1]);
	SendAdminMessage(white, msg);
	format(msg, sizeof msg, "|| "cred"Administrator %s has setted your VirtualWorld ID to %d "cwhite"||", GetPName(playerid), params[1]);
	SendClientMessage(params[0], white, msg);
	SetPlayerVirtualWorld(params[0], params[1]);
	return 1;
}

CMD:saveex(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
	    new msg[128];
		if(sscanf(params,"s[128]",msg)) return 1;
	    new Float:P[4], str[128], File:Fhnd, colores[2];
	    if(IsPlayerInAnyVehicle(playerid))
		{
	        new veh;
	        veh = GetPlayerVehicleID(playerid);
	        GetVehiclePos(veh, P[0], P[1], P[2]);
	        GetVehicleColor(veh, colores[0], colores[1]);
	        GetVehicleZAngle(veh, P[3]);
	        format(str, 128, "AddStaticVehicle(%i, %f, %f, %f, %f, %i, %i); // %s", GetVehicleModel(veh), P[0], P[1], P[2], P[3], colores[0], colores[1], msg);
	    }
		else
		{
	        GetPlayerPos(playerid, P[0], P[1], P[2]);
	        GetPlayerFacingAngle(playerid, P[3]);
	        format(str, 128, "AddPlayerClass(%i, %f, %f, %f, %f, 0, 0, 0, 0, 0, 0); // %s", GetPlayerSkin(playerid), P[0], P[1], P[2], P[3], msg);
	    }
	    if(fexist("savedpositions.txt"))
		{
	        Fhnd = fopen("savedpositions.txt", io_append);
	        fwrite(Fhnd, str);
	        fwrite(Fhnd, "\r\n");
	        fclose(Fhnd);
	    }
	    else
		{
	        Fhnd = fopen("savedpositions.txt", io_write);
	        fwrite(Fhnd, str);
	        fwrite(Fhnd, "\r\n");
	        fclose(Fhnd);
	    }
	    PlayerPlaySound(playerid, 1057, P[0], P[1], P[2]);
	    return SendClientMessage(playerid, 0x00FF00FF, "Posicion guardada exitosamente.");
	}
	return 1;
}

CMD:hideo(playerid, params[])
{
	if(Team[playerid] == 1 && PInfo[playerid][SPerk] == 10)
	{
		if(Activated{playerid})
		{
			new LongString[1_024];

			for(new o = 0; o < sizeof(ObjectInfo); o++)
			{
				format(LongString, sizeof(LongString), "%s{94ED40} %s\n", LongString, ObjectInfo[o][o_n]);
			}
			ShowPlayerDialog ( playerid, List, DIALOG_STYLE_LIST,
				"{94ED40}Objects",
				LongString,
				"OK",
				"X"
			);
			LongString[0] = EOS;
		}
		else
		{
			SendClientMessage(playerid, 0xFFFFFFFF, "ERROR: Enable the {94ED40}Stealth Mode{FFFFFF} perk.");
		}
	}
    return 1;
}

CMD:me(playerid,params[])
{
	new msg[128],string[128];
	if(sscanf(params,"s[128]",msg)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/me <message>");
	if(PInfo[playerid][Muted]) return SendClientMessage(playerid, red, "|| You can't talk because you're muted! ||");

	new temp[MAX_STRING];
	format(temp,sizeof temp,"%s",msg);
    if(!anti_ip(temp))
	{
		format(string,sizeof(string),""cjam"» %s %s",GetPName(playerid),msg);
		SendNearMessage(playerid,white,string,30);

		new
			ircMsg[256];
		format(ircMsg, sizeof(ircMsg), "13[CMD /me] » %s(%i) %s", GetPName(playerid), playerid, msg);
		IRC_GroupSay(gGroupID, IRC_CHANNEL, ircMsg);
	}
	return 1;
}

CMD:tpm(playerid,params[])
{
    new text[128],string[128];
	if(sscanf(params,"s[80]",text)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/tpm <text>");
	if(PInfo[playerid][Muted]) return SendClientMessage(playerid, red, "|| You can't talk because you're muted! ||");

	new temp[MAX_STRING];
	format(temp,sizeof temp,"%s",text);
    if(!anti_ip(temp))
	{
		format(string,sizeof string,"TPM from %s(%i): %s",GetPName(playerid),playerid,text);
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
			if(Team[i] == Team[playerid])
			{
			    SendClientMessage(i,0x00E1FFFF,string);
			}
		}

		new
			ircMsg[256];
		format(ircMsg, sizeof(ircMsg), "12TPM from %s(%i): %s", GetPName(playerid), playerid, text);
		IRC_GroupSay(gGroupID, IRC_CHANNEL, ircMsg);
	}
	return 1;
}

CMD:nopm(playerid,params[])
{
	#pragma unused params
	if(PInfo[playerid][NoPM] == 1)
	{
	    PInfo[playerid][NoPM] = 0;
	    SendClientMessage(playerid,white,"» "corange"You are now receiving all incoming PM's!");
 	}
 	else
 	{
 	    PInfo[playerid][NoPM] = 1;
	    SendClientMessage(playerid,white,"» "corange"You have blocked all incoming PM's!");
  	}
	return 1;
}

CMD:r(playerid,params[])
{
   	new string[256],text[80];
	if(sscanf(params,"s[80]",text)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/r <text>");
	if(PInfo[playerid][LastID] == -1) return SendClientMessage(playerid,white,"» "cred"No recent messages!");
	if(PInfo[PInfo[playerid][LastID]][NoPM] == 1) return SendClientMessage(playerid,white,"» "cred"That player does not want to be bother'd with PM's.");

	new temp[MAX_STRING];
	format(temp,sizeof temp,"%s",text);
	if(!anti_ip(temp))
	{
		format(string,sizeof(string),"PM from %s(%i): %s",GetPName(playerid),playerid,text);
		SendClientMessage(PInfo[playerid][LastID],0xFFFF22AA,string);
		format(string,sizeof(string),"PM sent to %s(%i): %s",GetPName(PInfo[playerid][LastID]),PInfo[playerid][LastID],text);
		SendClientMessage(playerid,0xFFCC2299,string);

		new
			ircMsg[256];
		format(ircMsg, sizeof(ircMsg), "8PM from %s(%i) to %s(%i): %s", GetPName(playerid), playerid, GetPName(PInfo[playerid][LastID]), PInfo[playerid][LastID], text);
		IRC_GroupSay(gGroupID, IRC_CHANNEL, ircMsg);
	}
	return 1;
}

CMD:pm(playerid,params[])
{
    new id,text[256],string[256];
	if(sscanf(params,"us[80]",id,text)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/pm <id> <text>");
	if(PInfo[id][NoPM] == 1) return SendClientMessage(playerid,white,"» "cred"That player does not want to be bother'd with PM's.");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,white,"» "cred"Player not found.");
	if(PInfo[playerid][Muted]) return SendClientMessage(playerid, red, "|| You can't talk because you're muted! ||");

	new temp[MAX_STRING];
	format(temp,sizeof temp,"%s",text);
    if(!anti_ip(temp))
	{
		format(string,sizeof(string),"PM from %s(%i): %s",GetPName(playerid),playerid,text);
		SendClientMessage(id,0xFFFF22AA,string);
		format(string,sizeof(string),"PM sent to %s(%i): %s",GetPName(id),id,text);
		SendClientMessage(playerid,0xFFCC2299,string);

		new
			ircMsg[256];
		format(ircMsg, sizeof(ircMsg), "8PM from %s(%i) to %s(%i): %s", GetPName(playerid), playerid, GetPName(id), id, text);
		IRC_GroupSay(gGroupID, IRC_CHANNEL, ircMsg);

		PInfo[id][LastID] = playerid;
	}
	return 1;
}

CMD:report(playerid,params[])
{
	new id,text[80],string[256];
	if(sscanf(params,"us[80]",id,text)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/report <id> <reason>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,white,"» "cred"Wrong ID to report.");

	new temp[MAX_STRING];
	format(temp,sizeof temp,"%s",text);
    if(!anti_ip(temp))
	{
		format(string,sizeof(string),"|| "cgreen"%s(%i) has reported %s(%i), reason: %s "cwhite"||", GetPName(playerid),playerid, GetPName(id), id, text);
		SendAdminMessage(white,string);
		SendClientMessage(playerid,green, "» Your report has been sent sucessfully.");

		new
			ircMsg[256];
		format(ircMsg, sizeof(ircMsg), "%s(%i) has reported to %s(%i): %s", GetPName(playerid), playerid, GetPName(id), id, text);
		IRC_GroupSay(gGroupID, IRC_CHANNEL, ircMsg);
	}
	return 1;
}

CMD:premiums(playerid,params[])
{
	new lvl[30],on;
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
	    if(PInfo[i][Premium] > 0) on++;
 	}
	SendFMessage(playerid, 0xF5DA81FF,"____ Premiums Online: %i ____",on);
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
	    if(PInfo[i][Premium] == 0) continue;
	    if(PInfo[i][Premium] == 1) lvl = ""cgold"Gold";
	    else if(PInfo[i][Premium] == 2) lvl = ""cplat"Platinum";
		SendFMessage(playerid,white,"- %s(%i) %s premium.",GetPName(i),i,lvl);
	}
	SendClientMessage(playerid, 0xF5DA81FF,"___________________________");
	return 1;
}

CMD:admins(playerid,params[])
{
	new lvl[10],on;
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
	    if(PInfo[i][Level] > 0) on++;
 	}
	SendFMessage(playerid,green,"____ Admins Online: %i ____",on);
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
	    if(PInfo[i][Level] == 0) continue;
	    if(PInfo[i][Level] == 1) lvl = "Trial";
	    else if(PInfo[i][Level] == 2) lvl = "General";
	    else if(PInfo[i][Level] == 3) lvl = "Senior";
	    else if(PInfo[i][Level] == 4) lvl = "Lead";
	    else if(PInfo[i][Level] == 5) lvl = "Head";
		else if(PInfo[i][Level] == 6 || IsPlayerAdmin(playerid)) lvl = "Developer";
		SendFMessage(playerid,green,"- %s(%i) %s administator.",GetPName(i),i,lvl);
	}
	SendClientMessage(playerid,green,"___________________________");
	return 1;
}

CMD:setav(playerid,params[])
{
	if(!IsPlayerAdmin(playerid)) return 0;
	new Float:x,Float:y,Float:z;
	if(sscanf(params,"fff",x,y,z)) return SendClientMessage(playerid,orange,"USAGE: /setav <x> <y> <z>");
	SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), x, y, z);
	return 1;
}

CMD:setzskin(playerid,params[])
{
    new skin;
	if(PInfo[playerid][Premium] == 0) return SendClientMessage(playerid,white,"* "cred"You are not allowed to use this command!");
	if(Team[playerid] != ZOMBIE) return SendClientMessage(playerid,white,"* "cred"You must be zombie to use the command.");
	if(sscanf(params,"i",skin)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setzskin <skinid>");
	if(skin < 1 || skin > 299) return SendClientMessage(playerid,red,"The skin id must be between 1 and 299");
	new valid = 0;
	for(new i = 0; i < sizeof(ZombieSkins); i++)
			if(skin == ZombieSkins[i]) valid = 1;
	if(valid == 0) return SendClientMessage(playerid,red,"That skin can't be used for zombies!");

	SetPlayerSkin(playerid,skin);
	SendClientMessage(playerid,orange,"You have successfully changed your zombie skin.");
	PInfo[playerid][ZSkin] = skin;
	SaveStats(playerid);
	return 1;
}

CMD:setsskin(playerid,params[])
{
    new skin;
	if(PInfo[playerid][Premium] == 0) return SendClientMessage(playerid,white,"* "cred"You are not allowed to use this command!");
	if(Team[playerid] != HUMAN) return SendClientMessage(playerid,white,"* "cred"You must be human to use the command.");
	if(sscanf(params,"i",skin)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setsskin <skinid>");
	if(skin < 1 || skin > 299) return SendClientMessage(playerid,red,"The skin id must be between 1 and 299");

	SetPlayerSkin(playerid,skin);
	SendClientMessage(playerid,orange,"You have successfully changed your survivor skin.");
	PInfo[playerid][SSkin] = skin;
	SaveStats(playerid);
	return 1;
}

CMD:setperk(playerid,params[])
{
	if(PInfo[playerid][Premium] == 0) return SendClientMessage(playerid,white,"* "cred"You are not allowed to use this command!");
	new perk,id;
	if(sscanf(params,"id",id,perk)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setsperk <team> <perkid> "cgrey"1 = Survivor | 2 = Zombie");
	if(perk > PInfo[playerid][Rank]) return SendClientMessage(playerid,white,"* "cred"You haven't the necesary rank to use that perk.");
	if(id == 1) PInfo[playerid][SPerk] = perk-1;
	else if(id == 2) PInfo[playerid][ZPerk] = perk-1;
	SendClientMessage(playerid,orange,"You have successfully changed your perk.");
	return 1;
}

CMD:help(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Help guide "cwhite"<<");
	SendClientMessage(playerid, white, ""cgold"Are you new to the server? Do you want to view a guide? "cwhite"Use /sguide (survivor) or /zguide (zombie)");
	SendClientMessage(playerid, white, ""cgold"Have you seen a cheater? "cwhite"Use /report <id> <reason>");
	SendClientMessage(playerid, white, ""cgold"Do you know our rules? "cwhite"Check it out using /rules");
	SendClientMessage(playerid, white, ""cgold"Alse we have basic command that you would like to use: "cwhite"Check it out using /commands");
	SendClientMessage(playerid, white, "To view the STAFF online use /admins | To view the premium members online use /premiums");
	return 1;
}

CMD:ayuda(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Guнa de ayuda "cwhite"<<");
	SendClientMessage(playerid, white, ""cgold"їEres nuevo en el servidor? їNecesitas saber quй hacer en tu equipo? "cwhite"Usa /sguia (humanos) o /zguia (zombies)");
	SendClientMessage(playerid, white, ""cgold"їHas visto algъn cheater? "cwhite"Usa /report <id> <motivo>");
	SendClientMessage(playerid, white, ""cgold"їAъn no has leнdo las reglas del servidor? "cwhite"Informate utilizando /reglas");
	return 1;
}

CMD:ajuda(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Ajuda "cwhite"<<");
	SendClientMessage(playerid, white, ""cgold"Vocк й novo no servidor? Gostaria de ver um guia? "cwhite"Use /guiahumano or /guiazumbi");
	SendClientMessage(playerid, white, ""cgold"Viu um hacker? "cwhite"Use /report <id> <motivo>");
	SendClientMessage(playerid, white, ""cgold"Vocк jб conhece as regras? "cwhite"Use /regras");
	SendClientMessage(playerid, white, ""cgold"Vocк й premium e gostaria de ver os seus comandos? "cwhite"Use /premiumhelp");
	return 1;
}

CMD:rushelp(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Руководство "cwhite"<<");
	SendClientMessage(playerid, white, ""cgold"Ты новичек? хочешь посмотреть как играть? "cwhite"Напиши команду /russguide ( для людей ) и /ruszguide ( для зомби )");
	SendClientMessage(playerid, white, ""cgold"Если ты видешь читера, "cwhite"напиши команду /report <id> <причину> ");
	SendClientMessage(playerid, white, ""cgold"Если ты хочешь узнать правила, "cwhite"напиши команду /rusrules");
	SendClientMessage(playerid, white, "Чтобы посмотреть администраторов в онлайне напиши /admins, чтобы посмотреть кто с премиумом напиши /premiums");
	return 1;
}

CMD:sguide(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Survivor guide "cwhite"<<");
	SendClientMessage(playerid, white, "The objective of the humans team is to complete all the 8 checkpoints scattered around the map.");
	SendClientMessage(playerid, white, "Staying in higher places will increase your chances of surviving. Join forces with your team to win.");
	SendClientMessage(playerid, white, "Make a good use of your ammo. Each level has an ability. Press "cred"Y "cwhite"to change your perk and - "cred"N "cwhite"- to open your inventory.");
	SendClientMessage(playerid, white, "You can search for items inside interiors by pressing - "cred"C "cwhite"-");
	SendClientMessage(playerid, white, "In order to win, the humans team has to complete all the checkpoints around the map.");
	return 1;
}

CMD:sguia(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Guнa del superviviente "cwhite"<<");
	SendClientMessage(playerid, white, "El objetivo de los supervivientes es completar los 8 puntos de control repartidos por el mapa.");
	SendClientMessage(playerid, white, "Sube a lugares altos para sobrevivir y ganar batallas. Une fuerzas con miemrbos de tu equipo.");
	SendClientMessage(playerid, white, "Haz un buen uso de tu municiуn. Cada nivel tiene su habilidad. Presiona "cred"Y "cwhite"para ver las habilidades.");
	SendClientMessage(playerid, white, ""cred"N "cwhite"- para ver tu inventario. Puedes buscar artнculos para tu inventario en interiores presionando - "cred"C "cwhite"-");
	SendClientMessage(playerid, white, "Para ganar la ronda, los supervivientes deberбn limpiar los 8 puntos de control.");
	return 1;
}

CMD:guiahumano(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Guia dos Humanos "cwhite"<<");
	SendClientMessage(playerid, white, "O objetivo dos humanos й completar todos os 8 Checkpoints espalhados pelo mapa.");
	SendClientMessage(playerid, white, "Ficar em lugares altos irгo aumentar as suas chances de sorbeviver. Fique com os outros humanos, eles irгo te ajudar.");
	SendClientMessage(playerid, white, "Faзo um bom uso da sua muniзгo. Todo o level tem uma habilidade diferente. Pressione "cred"Y "cwhite"para mudar a sua habilidade - "cred"N "cwhite"- para abrir o seu inventбrio.");
	SendClientMessage(playerid, white, "Vocк pode procurar itens em interiores pressionando - "cred"C "cwhite"-");
	SendClientMessage(playerid, white, "Para ganhar a partida, os humanos tem que completar todos os checkpoints.");
	return 1;
}

CMD:russguide(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"информация для людей "cwhite"<<");
	SendClientMessage(playerid, white, "Выжившие люди должны посещать красные точки на карте, это зона спасения.");
	SendClientMessage(playerid, white, "Если не приезжать в безопасную зону (чекпоинт), то у вас будет мало шансов выжить. Попробуйте с кем нибудь обьединиться для выживания.");
	SendClientMessage(playerid, white, "В безопасной зоне, она выделена как красная точка на карте, дают боеприпасы и опыт для повышения ранга. Можно нажать Y для своих способностей и N для инвентаря.");
	SendClientMessage(playerid, white, "Дополнительные вещи можно найти в домах если подойти к стрелке и нажать на - С -.");
	SendClientMessage(playerid, white, "Чтобы закончить раунд и быстрее выйграть, достаточно просто ездить на чекпоинты (красная точка на карте).");
	return 1;
}

CMD:zguide(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Zombie guide "cwhite"<<");
	SendClientMessage(playerid, white, "As a zombie, you have to infect the humans. "cgold"Right click "cwhite"near a human to bite him.");
	SendClientMessage(playerid, white, "The zombies team objective is to infect all the humans alive. Press - Y - to change your perk, as a zombie you don't an inventory.");
	SendClientMessage(playerid, white, "In order to win, the infection has to reach 100percent.");
	return 1;
}


CMD:zguia(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Guнa del zombie "cwhite"<<");
	SendClientMessage(playerid, white, "Siendo zombie deberбs infectar a los humanos. "cgold"Click derecho del ratуn "cwhite"cerca del humano repetidamente para morderle.");
	SendClientMessage(playerid, white, "El objetivo de йste equipo (zombies) es infectar a todos los humanos vivos. Presiona - Y - para ver tus habilidades como zombie.");
	SendClientMessage(playerid, white, "Para ganar, los zombies deberбn conseguir el 100 porcien de infecciуn.");
	return 1;
}

CMD:guiazumbi(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"Guia dos Zumbis "cwhite"<<");
	SendClientMessage(playerid, white, "Como um zumbi, vocк tem de infectar os humanos. "cgold"Pressione o botгo de mirar no seu mouse "cwhite"perto de um humano para morde-lo.");
	SendClientMessage(playerid, white, "O objetivo dos zumbis й infectar todos os humanos vivos. Pressione - Y - para mudar a sua habilidade, como um zumbi vocк nгo tem inventбrio.");
	SendClientMessage(playerid, white, "Para ganhar a partida, a infecзгo deve atingir 100%.");
	return 1;
}

CMD:ruszguide(playerid, params[])
{
	SendClientMessage(playerid, white, ">> "cgold"информация для зомби "cwhite"<<");
	SendClientMessage(playerid, white, "Если ты играешь за зомби тебе необходимо убить всех выживших, кусая их ПРАВОЙ кнопкой мыши.");
	SendClientMessage(playerid, white, "Раунд закончиться если зомби заразят и убьют всех до последнего выжившего. Нажав на -Y- вы откроете способности у зомби и у них нет инвенторя.");
	SendClientMessage(playerid, white, "Для победы необходимо набрать 100% зараженных.");
	return 1;
}

CMD:rules(playerid, params[])
{
    SendClientMessage(playerid, white, ">> "cgold"Server Rules "cwhite"<<");
    SendClientMessage(playerid, white, ""cred"1. "cwhite"Do not bunnyhop. "cred"2. "cwhite"Do not TeamKill. "cred"3. "cwhite"Do not use_Cheats.");
    SendClientMessage(playerid, white, ""cred"4. "cwhite"Do not Jump + Med. "cred"5. "cwhite"Do not XP Abuse. "cred"6. "cwhite"Do not Fake-Kills.");
    SendClientMessage(playerid, white, ""cred"7. "cwhite"Do not Bait Bug. "cred"8. "cwhite"Do not insult, RESPECT.");
	return 1;
}

CMD:reglas(playerid, params[])
{
    SendClientMessage(playerid, white, ">> "cgold"REGLAS "cwhite"<<");
    SendClientMessage(playerid, white, ""cred"1. "cwhite"No se permite bunnyhop. "cred"2. "cwhite"No se permite matar a tus compaсeros de equipo. "cred"3. "cwhite"No usar cheats.");
    SendClientMessage(playerid, white, ""cred"4. "cwhite"No estб permitido saltar para curarse. "cred"5. "cwhite"No abusar de la experiencia. "cred"6. "cwhite"No hacer Fake-Kills.");
    SendClientMessage(playerid, white, ""cred"7. "cwhite"No se permite bugear habilidad 10 de humanos. "cred"8. "cwhite"No se permite insultar para ofender, RESPETO.");
	return 1;
}

CMD:regras(playerid, params[])
{
    SendClientMessage(playerid, white, ">> "cgold"Regras do Servidor "cwhite"<<");
    SendClientMessage(playerid, white, ""cred"1. "cwhite"Nгo faзa bunnyhop (pular para ganhar velocidade). "cred"2. "cwhite"Nгo ataque os seus companheiros de equipe. "cred"3. "cwhite"Nгo use cheats.");
    SendClientMessage(playerid, white, ""cred"4. "cwhite"Nгo pule + use medkits. "cred"5. "cwhite"Nгo abuse da XP. "cred"6. "cwhite"Nгo faзa fake-kills.");
    SendClientMessage(playerid, white, ""cred"7. "cwhite"Nгo faзa bait bug. "cred"8. "cwhite"Nгo insulte, respeite as pessoas.");
	return 1;
}

CMD:rusrules(playerid, params[])
{
    SendClientMessage(playerid, white, ">> "cgold"общие правила на сервере "cwhite"<<");
    SendClientMessage(playerid, white, ""cred"1. "cwhite"Нельзя часто прыгать. "cred"2. "cwhite"Своих не убивать. "cred"3. "cwhite"Не использовать читы.");
    SendClientMessage(playerid, white, ""cred"4. "cwhite"Нельзя одновременно прыгнуть и использовать при этом аптечку. "cred"5. "cwhite"Нельзя обманывать с XP. "cred"6. "cwhite"Нельзя подстаривать убийства для XP.");
    SendClientMessage(playerid, white, ""cred"7. "cwhite"Нельзя закидывать в недоступные места приманку для зомби. "cred"8. "cwhite"Нельзя обзывать кого-то, уважайте друг друга.");
	return 1;
}

CMD:l(playerid,params[])
{
    new text[128];
	if(sscanf(params,"s[128]",text)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/l <text>");
	if(PInfo[playerid][Muted]) return SendClientMessage(playerid, red, "|| You can't talk because you're muted! ||");

	new temp[MAX_STRING];
	format(temp,sizeof temp,"%s",text);
    if(!anti_ip(temp))
	{
		new string[134];
	 	format(string,sizeof string,"%s: %s",GetPName(playerid),text);
		SendNearMessage(playerid,white,string,30);

		new
			ircMsg[256];
		format(ircMsg, sizeof(ircMsg), "9[Local] %s(%i): 1%s", GetPName(playerid), playerid, text);
		IRC_GroupSay(gGroupID, IRC_CHANNEL, ircMsg);
	}
	return 1;
}

CMD:heal(playerid,params[])
{
	if(PInfo[playerid][Level] < 3) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/heal <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
    new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has healed %s(%i) ||",GetPName(playerid),playerid,GetPName(id),id);
	SendAdminMessage(red,string);
	SetPlayerHealth(id,100);
	return 1;
}

CMD:freeze(playerid,params[])
{
	if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/freeze <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
    new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has frozen %s(%i) ||",GetPName(playerid),playerid,GetPName(id),id);
	SendClientMessageToAll(red,string);
	TogglePlayerControllable(id, false);
	return 1;
}

CMD:unfreeze(playerid,params[])
{
	if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid, red,"USAGE: /unfreeze <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, red, "That player is not connected!");
    new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has unfrozen %s(%i) ||",GetPName(playerid),playerid,GetPName(id),id);
	SendClientMessageToAll(red,string);
	TogglePlayerControllable(id, true);
	return 1;
}

CMD:getip(playerid, params[])
{
	new target, string[144];
	if(PInfo[playerid][Level] < 4) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(sscanf(params, "u", target)) return SendClientMessage(playerid, red, "USAGE: /getip <Part of name/ID>");
	if(!IsPlayerConnected(target)) return SendClientMessage(playerid, red, "Incorrect ID !");
	new pip[16], pname[25];
	GetPlayerIp(target, pip, sizeof(pip));
	GetPlayerName(target, pname, sizeof(pname));
	format(string, sizeof(string), "|| "cred"IP of %s: %s "cwhite"||", pname, pip);
	SendClientMessage(playerid, white, string);
	return 1;
}

CMD:jail(playerid,params[])
{
    new id,time,reason[100], szString[128];
    if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
    if(sscanf(params,"dds",id,time,reason)) return SendClientMessage(playerid, red, "USAGE: /jail <playerid> <time> <reason>");
    if (!IsPlayerConnected(id)) return SendClientMessage(playerid, red, "ERROR: Player is not connected.");
    if(Jailed[id] == 1) return SendClientMessage(playerid, red, "ERROR: Player is already jailed.");

	format(szString, sizeof(szString), "|| Admin %s has jailed %s (ID:%d) for %d minutes. Reason: %s ||", GetPName(playerid), GetPName(id), id, time, reason);
	SendClientMessageToAll(red, szString);
	SetPlayerInterior(id, 3);
	SetPlayerVirtualWorld(id, 10);
	SetPlayerFacingAngle(id, 360.0);
	SetPlayerPos(id, 197.5662, 175.4800, 1004.0);
	SetPlayerHealth(id, 9999999999.0);
	Jailed[id] = 1;
	ResetPlayerWeapons(id);
	JailTimer[id] = SetTimerEx("Unjail",time*60000, false, "i", id);
	return 1;
}

CMD:unjail(playerid,params[])
{
    new id;
	if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(sscanf(params,"u",id)) return SendClientMessage(playerid, red, "USAGE: /unjail <playerid>");
	if (!IsPlayerConnected(id)) return SendClientMessage(playerid, red, "ERROR: Player is not connected.");
	if(Jailed[id] == 0) return SendClientMessage(playerid, red, "ERROR: Player is not jailed.");
 	Jailed[id] = 0;
	SetPlayerInterior(id, 0);
	SetPlayerVirtualWorld(id, 0);
	SpawnPlayer(id);
	SetPlayerHealth(id, 100);
	KillTimer(JailTimer[id]);
	return 1;
}

CMD:mute(playerid,params[])
{
	new plid,reason[64];
	if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(sscanf(params,"us[64]",plid,reason)) return SendClientMessage(playerid, red,"USAGE: /mute <playerid> <reason>");
	if(!IsPlayerConnected(plid)) return SendClientMessage(playerid, red,"That player is not connected!");
	new adminname[MAX_PLAYER_NAME],playername[MAX_PLAYER_NAME],string[256];
	GetPlayerName(playerid,adminname,sizeof(adminname));
	GetPlayerName(plid,playername,sizeof(playername));
 	format(string,sizeof(string),"|| "cred"%s has been muted by %s, reason: %s "cwhite"||", playername, adminname, reason);
	SendClientMessageToAll(white,string);
	PInfo[plid][Muted]=1;
	return 1;
}

CMD:unmute(playerid,params[])
{
	new plid;
	if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(sscanf(params,"u",plid)) return SendClientMessage(playerid,red,"INFO: /unmute <playerid> <reason>");
	if(!IsPlayerConnected(plid)) return SendClientMessage(playerid,red,"No such player");
	new adminname[MAX_PLAYER_NAME],playername[MAX_PLAYER_NAME],string[256];
	GetPlayerName(playerid,adminname,sizeof(adminname));
	GetPlayerName(plid,playername,sizeof(playername));
 	format(string,sizeof(string),"|| "cred"%s has been unmuted by %s "cwhite"||", playername, adminname);
	SendClientMessageToAll(white,string);
	PInfo[plid][Muted]=0;
	return 1;
}

CMD:acmds(playerid,params[])
{
	if(PInfo[playerid][Level] == 0) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
    if(PInfo[playerid][Level] >= 1)
	{
		SendClientMessage(playerid, white,"* "cgreen"Admin Commands "cwhite"*");
		SendClientMessage(playerid, white,"* "cgreen"Chat admin: # ( Example: # Hey there! ) "cwhite"*");
		SendClientMessage(playerid, white,""cgreen"Trial admin commands: "cwhite"/slap - /saveuser - /kick - /setteam - /(un)freeze - /spec(off)");
		SendClientMessage(playerid, white,""cgreen"Trial admin commands: "cwhite"/(un)mute - /(un)jail - /cc(clearchat) - /aod (AdminOnDuty)");
	}
	if(PInfo[playerid][Level] >= 2) SendClientMessage(playerid, white,""cgreen"General admin commands: "cwhite"/goto - /get - /warn - /setint - /setvw - /say");
	if(PInfo[playerid][Level] >= 3) SendClientMessage(playerid, white,""cgreen"Senior admin commands: "cwhite"/heal - /bslap - /ban - /announce");
	if(PInfo[playerid][Level] >= 4) SendClientMessage(playerid, white,""cgreen"Lead admin commands: "cwhite"/sethealth - /setarmour - /rape - /getip - /rangeban - /makeleader - /gotopumpkin");
	if(PInfo[playerid][Level] >= 5)
	{
		SendClientMessage(playerid, white,""cgreen"Head admin commands: "cwhite"/nuke - /savecar - /setlevel (rcon) - /setprem - /setname - /createveh - /airdrop - /gotoairdrop");
		SendClientMessage(playerid, white,""cgreen"User's account cmds: "cwhite"/setrank - /setxp - /setkills - /setdeaths - /setinfects - /settks");
	}
	return 1;
}

CMD:sethealth(playerid,params[])
{
	if(PInfo[playerid][Level] < 4) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,health;
	if(sscanf(params,"ui",id,health)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/sethealth <id> <health>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
    new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has setted %s(%i) health to %i ||",GetPName(playerid),playerid,GetPName(id),id,health);
	SendAdminMessage(red,string);
	SetPlayerHealth(id,health);
	return 1;
}

CMD:setarmour(playerid,params[])
{
	if(PInfo[playerid][Level] < 4) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,arm;
	if(sscanf(params,"ui",id,arm)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setarmour <id> <health>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
    new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has setted %s(%i) armour to %i ||",GetPName(playerid),playerid,GetPName(id),id,arm);
	SendAdminMessage(red,string);
	SetPlayerArmour(id,arm);
	return 1;
}

CMD:nuke(playerid,params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/nuke <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(id,x,y,z);
	CreateExplosion(x,y,z,7,1000);
	new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has nuked %s(%i) ||",GetPName(playerid),playerid,GetPName(id),id);
	SendClientMessageToAll(red,string);
	return 1;
}

CMD:rape(playerid,params[])
{
	if(PInfo[playerid][Level] < 4) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/rape <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	SetPlayerHealth(id,1);
	SetPlayerArmour(id,0);
    SetPlayerSkin(id,137);
    SetPlayerWeather(id,16);
    SetPlayerDrunkLevel(id,5000);
	ResetPlayerWeapons(id);
	new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has raped %s(%i) ||",GetPName(playerid),playerid,GetPName(id),id);
	SendClientMessageToAll(red,string);
	return 1;
}

CMD:bslap(playerid,params[])
{
	if(PInfo[playerid][Level] < 3) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/bslap <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(id,x,y,z);
	SetPlayerPos(id,x,y,z+9);
	new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has bitched slapped %s(%i) ||",GetPName(playerid),playerid,GetPName(id),id);
	SendClientMessageToAll(red,string);
	return 1;
}

CMD:slap(playerid,params[])
{
	if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/slap <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(id,x,y,z);
	SetPlayerPos(id,x,y,z+6);
	new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has slapped %s(%i) ||",GetPName(playerid),playerid,GetPName(id),id);
	SendClientMessageToAll(red,string);
	return 1;
}

CMD:saveuser(playerid,params[])
{
    if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
    new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/saveuser <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	new string[90];
	format(string,sizeof string,"|| Administrator %s(%i) has saved %s's account ||",GetPName(playerid),playerid,GetPName(id));
	SendAdminMessage(red,string);
	SaveStats(id);
	return 1;
}

CMD:ss(playerid,params[])
{
	if(!IsPlayerConnected(playerid)) return 1;
	SendClientMessage(playerid, white, "|| "cgreen"Your account has been saved sucessfully. "cwhite"||");
	SaveStats(playerid);
	return 1;
}

CMD:savestats(playerid, params[])
{
	return cmd_ss(playerid, params);
}

CMD:goto(playerid,params[])
{
    if(PInfo[playerid][Level] < 2) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/goto <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(id,x,y,z);
	if(IsPlayerInAnyVehicle(playerid))
	{
	    SetVehiclePos(GetPlayerVehicleID(playerid),x,y+3,z);
	}
	else SetPlayerPos(playerid,x,y+3,z);
	SetPlayerInterior(playerid,GetPlayerInterior(id));
	new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has teleported to %s(%i) ||",GetPName(playerid),playerid,GetPName(id),id);
	SendAdminMessage(red,string);
	return 1;
}

CMD:announce(playerid,params[])
{
    if(PInfo[playerid][Level] < 3) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new style, seconds, text[40];
	if(sscanf(params,"dds[40]",style, seconds, text)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/announce <style> <seconds(1,2,3..)> <text>");
	if(style == 3) return SendClientMessage(playerid, red, "Style bugged, please use: 1, 2, 4, 5 or 6.");
	if(strlen(text) > 40) return SendClientMessage(playerid, red, "Text too large.");
	GameTextForAll(text, seconds*1000, style);
	return 1;
}

CMD:say(playerid,params[])
{
    if(PInfo[playerid][Level] < 2) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new text[128], st[145];
	if(sscanf(params,"s[145]", text)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/say <text>");
	if(strlen(text) > 128) return SendClientMessage(playerid, red, "Text too large.");
	format(st, sizeof st, "[eG] Administration: "cwhite"%s", text);
	SendClientMessageToAll(0x3E5374FF, st);
	return 1;
}

CMD:spec(playerid, params[])
{
	new id;
	if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(sscanf(params,"u", id)) return SendClientMessage(playerid, red, "Usage: /spec [id]");
	if(id == playerid)return SendClientMessage(playerid,red,"You cannot spec yourself.");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, red, "Player not found!");
	if(IsSpecing[playerid] == 1) return SendClientMessage(playerid,red,"You are already specing someone.");
	GetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);
	Inter[playerid] = GetPlayerInterior(playerid);
	vWorld[playerid] = GetPlayerVirtualWorld(playerid);
	TogglePlayerSpectating(playerid, true);
	if(IsPlayerInAnyVehicle(id))
	{
	    if(GetPlayerInterior(id) > 0)
	    {
			SetPlayerInterior(playerid,GetPlayerInterior(id));
		}
		if(GetPlayerVirtualWorld(id) > 0)
		{
		    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
		}
	    PlayerSpectateVehicle(playerid,GetPlayerVehicleID(id));
	}
	else
	{
	    if(GetPlayerInterior(id) > 0)
	    {
			SetPlayerInterior(playerid,GetPlayerInterior(id));
		}
		if(GetPlayerVirtualWorld(id) > 0)
		{
		    SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
		}
	    PlayerSpectatePlayer(playerid,id);
	}
	for(new w=0; w < 13; w++) GetPlayerWeaponData(playerid, w, specweps[playerid][w][0], specweps[playerid][w][1]);

	format(String, sizeof(String),"|| Administrator %s is specting %s (ID: %i) ||",GetPName(playerid), GetPName(id), id);
	SendAdminMessage(red, String);
	IsSpecing[playerid] = 1;
	IsBeingSpeced[id] = 1;
	spectatorid[playerid] = id;
 	return 1;
}

CMD:specoff(playerid, params[])
{
	if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(IsSpecing[playerid] == 0) return SendClientMessage(playerid,red,"You are not spectating anyone.");
	TogglePlayerSpectating(playerid, 0);
	return 1;
}

CMD:kick(playerid,params[])
{
    if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,reason[40];
	if(sscanf(params,"us[40]",id,reason)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/kick <id> <reason>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	if(IsPlayerNPC(id)) return SendClientMessage(playerid,red,"You can't kick to the Sgt Soap!");

	new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has kicked to %s [Reason: %s] ||",GetPName(playerid),playerid,GetPName(id),reason);
	SendClientMessageToAll(red,string);

	KickEx(id);
	SaveIn("Kicklog",string,1);
	return 1;
}

CMD:ban(playerid,params[])
{
    if(PInfo[playerid][Level] < 3) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,reason[40];
	if(sscanf(params,"us[40]",id,reason)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/ban <id> <reason>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	if(IsPlayerNPC(id)) return SendClientMessage(playerid,red,"You can't ban our NPC! .l.");
	if(PInfo[playerid][Level] < PInfo[id][Level]) return SendClientMessage(playerid,red,"You can't ban a higher administrator than you!");
    SendFMessageToAll(red,"|| Administrator %s(%i) has banned %s [Reason: %s] ||",GetPName(playerid),playerid,GetPName(id),reason);
	new string[500],y,mm,d;
	getdate(y,mm,d);

	format(string,sizeof string,"Administrator %s has banned %s. Reason: %s",GetPName(playerid),GetPName(id),reason);
	SaveIn("Banlog",string,1);

	format(string,sizeof string ,""corange"Administrator name: %s \nYour name: %s \nYour IP Address: %s \nReason why you got banned: %s. \nDate: %d/%d/%d \n\n\n\t"cgreen"Take a picture of this box and post an unban appeal at www.extreme-stunting.com if you wish.",GetPName(playerid),GetPName(id),GetIP(id),reason,d,mm,y);
	ShowPlayerDialog(id,4533,0,""cred"You have been banned - read the following details!",string,"Close","");

	new str[64];
    format(DB_Query, sizeof(DB_Query), "");
	strcat(DB_Query, "UPDATE USERS SET ");
	format(str, 64, "Banned = '%d'", 1); strcat(DB_Query, str);
    format(str, 64, " WHERE NAME = '%s'", GetPName(playerid)); strcat(DB_Query, str);
	db_query(Database, DB_Query);

	format(string,sizeof string,"%s has banned %s.",GetPName(playerid),GetPName(id));
	P_BanEx(id, string);
	return 1;
}

CMD:get(playerid,params[])
{
    if(PInfo[playerid][Level] < 2) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id;
	if(sscanf(params,"u",id)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/get <id>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"That player is not connected!");
	if(IsPlayerNPC(id)) return SendClientMessage(playerid,red,"You can't get our NPC! .l.");
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	if(IsPlayerInAnyVehicle(id))
	{
	    SetVehiclePos(GetPlayerVehicleID(id),x,y+3,z);
	}
	else SetPlayerPos(id,x,y+3,z);
	SetPlayerInterior(id, GetPlayerInterior(playerid));
	new string[100];
	format(string,sizeof string,"|| Administrator %s(%i) has teleported %s(%i) to his location ||",GetPName(playerid),playerid,GetPName(id),id);
	SendAdminMessage(red,string);
	return 1;
}

CMD:createveh(playerid, params[])
{
    if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(sscanf(params, "dd", params[0], params[1])) return SendClientMessage(playerid, red, "USAGE: /createveh <ID> <ID Color>");
	new Float:cpos[3];
	GetPlayerPos(playerid, cpos[0], cpos[1], cpos[2]);
	new vehcreated = CreateVehicle(params[0], cpos[0], cpos[1], cpos[2], 0.0, params[1], params[1], 300000);
	PutPlayerInVehicle(playerid, vehcreated, 0);
	return 1;
}

CMD:savecar(playerid,params[])
{
    #pragma unused params
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,red,"You must be in a vehicle!");
	new Float:x,Float:y,Float:z,Float:angle,vehicleid,string[164],c1,c2;
	vehicleid = GetPlayerVehicleID(playerid);
	GetVehicleZAngle(vehicleid,angle);
	GetVehicleColor(vehicleid,c1,c2);
	GetVehiclePos(vehicleid,x,y,z);
	new File:example = fopen("Admin/Allcars.txt", io_append);
	format(string,sizeof(string),"%i,%f,%f,%f,%f,%i,%i;\r\n",GetVehicleModel(vehicleid),x,y,z,angle,c1,c2);
	fwrite(example,string);
	fclose(example);
	format(string,sizeof(string),"» Vehicle: %i has been saved.",GetVehicleModel(vehicleid));
	SendClientMessage(playerid,green,string);
	return 1;
}

CMD:perks(playerid,params[])
{
	if(Team[playerid] == HUMAN)
	{
	    ShowPlayerHumanPerks(playerid);
	}
	if(Team[playerid] == ZOMBIE)
	{
	    ShowPlayerZombiePerks(playerid);
	}
	return 1;
}

CMD:setteam(playerid,params[])
{
    if(PInfo[playerid][Level] < 1) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,team;
	if(sscanf(params,"ui",id,team)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setteam <id> <1 = Human | 2 = Zombie>");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	if(IsPlayerNPC(id)) return SendClientMessage(playerid,red,"You can't set the team to our NPC! .l.");
	if(team == ZOMBIE)
	{
	    SetSpawnInfo(id,0,ZombieSkins[random(sizeof(ZombieSkins))],0,0,0,0,0,0,0,0,0,0);
	    SetPlayerSkin(id,ZombieSkins[random(sizeof(ZombieSkins))]);
	    SpawnPlayer(id);
	    Team[id] = ZOMBIE;
	    SpawnPlayer(id);
	    SetPlayerColor(id,purple);
	    SetPlayerHealth(id,100);
	    SendFMessageToAll(red, "» Administrator %s(%i) has set %s(%i) team to Zombie.", GetPName(playerid),playerid,GetPName(id),id);
  	}
  	else if(team == HUMAN)
	{
	    Team[id] = HUMAN;
	    new sid;
		ChooseSkin: sid = random(299);
		sid = random(299);
		for(new i = 0; i < sizeof(ZombieSkins); i++)
			if(sid == ZombieSkins[i]) goto ChooseSkin;
    	SetSpawnInfo(id,0,sid,0,0,0,0,0,0,0,0,0,0);
	    SetPlayerSkin(id,sid);
	    PInfo[id][JustInfected] = 0;
	    PInfo[id][Infected] = 0;
		PInfo[id][Dead] = 0;
		PInfo[id][CanBite] = 1;
		SpawnPlayer(id);
		SetPlayerColor(id,green);
		SetPlayerHealth(id,100);
		SendFMessageToAll(red, "» Administrator %s(%i) has set %s(%i) team to Survivor.", GetPName(playerid),playerid,GetPName(id),id);
	}
	else return SendClientMessage(playerid,red,"Team not found!");
	return 1;
}

CMD:setlevel(playerid,params[])
{
	new id,level;
	if(sscanf(params,"ui",id,level)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setlevel <id> <level>");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	if(!IsPlayerAdmin(playerid) || PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(!IsPlayerAdmin(playerid) && PInfo[id][Level] > 4) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	if(level > 6) return SendClientMessage(playerid,red,"Maximum admin level is 6!");
	SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) admin level to %i",GetPName(playerid),playerid,GetPName(id),id,level);
	if(level > PInfo[id][Level])
	    GameTextForPlayer(id,"~g~~h~Promoted!",4000,3);
	else
	    GameTextForPlayer(id,"~r~~h~Demoted!",4000,3);
	PInfo[id][Level] = level;
	SaveStats(id);
	return 1;
}

CMD:setname(playerid, params[])
{
    if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id, newname[24], str[91], oldname[24];
	if(sscanf(params, "is[24]", id, newname)) return SendClientMessage(playerid, red, "USAGE: "cwhite"/setname <ID> <New Name>");
	if(IsPlayerNPC(id)) return SendClientMessage(playerid,red,"You can't change the name to my bot, bish.");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");

	new DBResult:Result, exists;
	format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", newname);
	Result = db_query(Database, DB_Query);
	if(db_num_rows(Result))	exists = true;
	db_free_result(Result);

	if(exists) return SendClientMessage(playerid,red,"» Error: That nickname is already in use!");

	GetPlayerName(id, oldname, 24);

	format(str,sizeof str,"UPDATE USERS SET NAME = '%s' WHERE NAME = '%s'", newname, oldname);
    db_query(Database, str);

	SendFMessageToAll(red,"|| Administrator %s has changed %s's name to %s ||",GetPName(playerid), GetPName(id), newname);

	SetPlayerName(id, newname);
	return 1;
}

CMD:warn(playerid,params[])
{
	if(PInfo[playerid][Level] < 2) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,warn[64],string[400],string2[128], str[128];
	if(sscanf(params,"us[64]",id,warn)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/warn <id> <warn>");
	if(IsPlayerNPC(id)) return 1;
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");

	format(string,sizeof string,"» Administrator %s(%i) has warned %s(%i) [Reason: %s]",GetPName(playerid),playerid,GetPName(id),id,warn);
	SendAdminMessage(red,string);
	PInfo[id][Warns]+=1;

    new DBResult:Result;
    format(DB_Query, sizeof(DB_Query), "");
	strcat(DB_Query, "UPDATE USERS SET ");
	format(str, 64, "Warns = '%i',", PInfo[id][Warns]); strcat(DB_Query, str);
	if(PInfo[id][Warns] == 1) format(str, 64, "WARN1 = '%s'", warn); strcat(DB_Query, str); PInfo[id][Warn1] = warn;
	if(PInfo[id][Warns] == 2) format(str, 64, "WARN2 = '%s'", warn); strcat(DB_Query, str); PInfo[id][Warn2] = warn;
	if(PInfo[id][Warns] == 3) format(str, 64, "WARN3 = '%s'", warn); strcat(DB_Query, str); PInfo[id][Warn3] = warn;
	format(str, 64, " WHERE NAME = '%s'", GetPName(id)); strcat(DB_Query, str);
	db_query(Database, DB_Query);

	SendFMessage(id,white,"» "cred"You have %i warnings.", PInfo[playerid][Warns]);

	if(PInfo[id][Warns] >= 3)
	{
		new d,mm,y;
		getdate(y,mm,d);
		format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
		Result = db_query(Database, DB_Query);
		if(db_num_rows(Result))
		{
			db_get_field(Result, 22, PInfo[id][Warn1], 64);
			db_get_field(Result, 23, PInfo[id][Warn2], 64);
			db_get_field(Result, 24, PInfo[id][Warn3], 64);
		}
		db_free_result(Result);

		format(DB_Query, sizeof(DB_Query), "");
		strcat(DB_Query, "UPDATE USERS SET ");
		format(str, 64, "BANNED = '%d'", 1); strcat(DB_Query, str);
	    format(str, 64, " WHERE NAME = '%s'", GetPName(id)); strcat(DB_Query, str);
		db_query(Database, DB_Query);

		SendFMessageToAll(red,"|| Administrator %s(%i) has banned %s(%i) [Reason: 3 Warnings]",GetPName(playerid),playerid,GetPName(id),id);
		SendFMessageToAll(red,"|| Warning 1: %s ||", PInfo[id][Warn1]);
		SendFMessageToAll(red,"|| Warning 2: %s ||", PInfo[id][Warn2]);
		SendFMessageToAll(red,"|| Warning 3: %s ||", PInfo[id][Warn3]);
		format(string2,sizeof string2,"has been banned. Reason: 3 warnings");
		format(string,sizeof(string),""corange"Administrator name: %s \nYour name: %s \nYour IP Address: %s \nReason why you got banned: 3 Warnings. \nDate: %d/%d/%d \n\n\n\t"cgreen"Take a picture of this box and post an unban appeal at www.eternal-games.net if you wish.",GetPName(playerid),GetPName(id),GetIP(id),d,mm,y);
		ShowPlayerDialog(id,4533,0,""cred"You have been banned - read the following details!",string,"Close","");

		BanEx(id, string2);
	}
	return 1;
}

CMD:setprem(playerid,params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,prem;
	if(sscanf(params,"ui",id,prem)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setprem <id> <premium> "cgrey"1 = Gold | 2 = Platinium");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	if(prem > 2 && prem < 0) return SendClientMessage(playerid,red,"Maximum admin level is 5!");
	ResetPlayerInventory(id);
	if(prem == 1)
	{
	    SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) premium to "cgold"Gold",GetPName(playerid),playerid,GetPName(id),id);
		if(Team[id] == HUMAN)
			SetPlayerArmour(id,100);
        AddItem(id,"Small Medical Kits",17);
     	AddItem(id,"Medium Medical Kits",17);
	    AddItem(id,"Large Medical Kits",17);
	    AddItem(id,"Fuel",17);
	    AddItem(id,"Oil",17);
	    AddItem(id,"Flashlight",17);
	    AddItem(id,"Dizzy Pills",17);
	}
	else if(prem == 2)
	{
	    SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) premium to "cplat"Platinium",GetPName(playerid),playerid,GetPName(id),id);
		if(Team[id] == HUMAN)
			SetPlayerArmour(id,150);
        AddItem(id,"Small Medical Kits",21);
     	AddItem(id,"Medium Medical Kits",21);
	    AddItem(id,"Large Medical Kits",21);
	    AddItem(id,"Fuel",21);
	    AddItem(id,"Oil",21);
	    AddItem(id,"Flashlight",21);
	    AddItem(id,"Dizzy Pills",21);
	    AddItem(id,"Molotovs Guide",1);
	    AddItem(id,"Bouncing Bettys Guide",1);
	}
	else
	{
	    SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) premium to None.",GetPName(playerid),playerid,GetPName(id),id);
		SetPlayerArmour(id,0);
		AddItem(id,"Small Medical Kits",5);
	    AddItem(id,"Medium Medical Kits",4);
        AddItem(id,"Large Medical Kits",3);
        AddItem(id,"Fuel",3);
        AddItem(id,"Oil",3);
        AddItem(id,"Flashlight",3);
	}
	PInfo[id][Premium] = prem;
	SaveStats(id);
	return 1;
}

CMD:setrank(playerid,params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,level;
	if(sscanf(params,"ui",id,level)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setrank <id> <rank>");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) rank to %i",GetPName(playerid),playerid,GetPName(id),id,level);
	PInfo[id][Rank] = level;
	ResetPlayerWeapons(id);
	CheckRankup(id,1);
	SaveStats(id);
	return 1;
}

CMD:setxp(playerid,params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,xp;
	if(sscanf(params,"ui",id,xp)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setxp <id> <xp>");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) XP to %i",GetPName(playerid),playerid,GetPName(id),id,xp);
	PInfo[id][XP] = xp;
	CheckRankup(id);
	SaveStats(id);
	return 1;
}

CMD:setkills(playerid,params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,xp;
	if(sscanf(params,"ui",id,xp)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setkills <id> <kills>");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) kills to %i",GetPName(playerid),playerid,GetPName(id),id,xp);
	PInfo[id][Kills] = xp;
	SaveStats(id);
	return 1;
}

CMD:settks(playerid,params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,tk;
	if(sscanf(params,"ui",id,tk)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/settks <id> <teamkills>");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) teamkills to %i",GetPName(playerid),playerid,GetPName(id),id,tk);
	PInfo[id][Teamkills] = tk;
	SaveStats(id);
	return 1;
}

CMD:setdeaths(playerid,params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,xp;
	if(sscanf(params,"ui",id,xp)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setdeaths <id> <deaths>");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) deaths to %i",GetPName(playerid),playerid,GetPName(id),id,xp);
	PInfo[id][Deaths] = xp;
	SaveStats(id);
	return 1;
}

CMD:setinfects(playerid,params[])
{
	if(PInfo[playerid][Level] < 5) return SendClientMessage(playerid,white,"» Error: "cred"You must be an administrator to use this command");
	new id,xp;
	if(sscanf(params,"ui",id,xp)) return SendClientMessage(playerid,orange,"USAGE: "cblue"/setinfects <id> <deaths>");
	if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid,red,"» Error: That player isn't connected!");
	SendFMessageToAll(red,"» Administrator %s(%i) has setted %s(%i) infects to %i",GetPName(playerid),playerid,GetPName(id),id,xp);
	PInfo[id][Infects] = xp;
	SaveStats(id);
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
    PlaySound(issuerid,6401);
    if(Team[issuerid] == HUMAN)
    {
	    if(PInfo[issuerid][SPerk] == 20 && GetPlayerWeapon(issuerid) == 0)
	    {
	        if(PInfo[issuerid][FireMode] == 1) return 0;
	        if(Team[playerid] == HUMAN) return 0;
	        if(Team[issuerid] == ZOMBIE) return 0;
	        if(PInfo[playerid][OnFire] != 0) return 0;
			PInfo[playerid][FireObject] = CreateObject(18692,0,0,0,0,0,0,200);
			PInfo[playerid][OnFire] = 1;
			PInfo[issuerid][FireMode] = 1;
			AttachObjectToPlayer(PInfo[playerid][FireObject],playerid,0,0,-0.2,0,0,0);
			SetTimerEx("CanUseFiremode",20000,false,"i",issuerid);
			SetTimerEx("AffectFire",500,false,"ii",playerid,issuerid);
	    }
	    if(PInfo[issuerid][Flamerounds] != 0 && GetPlayerWeapon(issuerid) != 0)
	    {
	        if(Team[issuerid] == ZOMBIE) return 0;
	        if(Team[playerid] == HUMAN) return 0;
	        DestroyObject(PInfo[playerid][FireObject]);
	        PInfo[issuerid][Flamerounds]--;
	        PInfo[playerid][OnFire] = 1;
	        PInfo[playerid][FireObject] = CreateObject(18692,0,0,0,0,0,0,200);
	        AttachObjectToPlayer(PInfo[playerid][FireObject],playerid,0,0,-0.2,0,0,0);
	        SetTimerEx("AffectFire",500,false,"ii",playerid,issuerid);
		}
	}
	else if(Team[issuerid] == ZOMBIE)
	{
	    if(PInfo[issuerid][ZPerk] == 6 && GetPlayerWeapon(issuerid) == 0)
	    {
	        new Float:x,Float:y,Float:z,Float:a,Float:health;
			GetPlayerVelocity(playerid,x,y,z);
			GetPlayerFacingAngle(issuerid,a);
			GetPlayerHealth(playerid,health);
			x += ( 0.5 * floatsin( -a, degrees ) );
	      	y += ( 0.5 * floatcos( -a, degrees ) );
			SetPlayerVelocity(playerid,x,y,z+0.2);
			if(health <= 10)
			    MakeProperDamage(playerid);
			else
   				SetPlayerHealth(playerid,health-5);
			GetPlayerHealth(playerid,health);
			MakeHealthEven(playerid,health);
			if(health <= 5)
			{
			    GetPlayerPos(playerid, ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2]);
			    GetPlayerFacingAngle(playerid, ZPS[playerid][3]);
			    SetSpawnInfo(playerid, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2], ZPS[playerid][3], 0, 0, 0, 0, 0, 0);
			    InfectPlayer(playerid);
			    GivePlayerXP(issuerid);
			    CheckRankup(issuerid);
			}
	    }
	}
    return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if(IsBeingSpeced[playerid] == 1)
	{
	    foreach(Player,i)
	    {
	    	if(spectatorid[i] == playerid)
			{
				SetPlayerInterior(i,GetPlayerInterior(playerid));
				SetPlayerVirtualWorld(i,GetPlayerVirtualWorld(playerid));
			}
		}
	}
	return 1;
}

public OnPlayerStateChange(playerid,newstate,oldstate)
{
	/*-------------- ANTI G BUG -------------------*/
    if(newstate == PLAYER_STATE_PASSENGER) {
		if(!g_EnterAnim{playerid}) {
			SetPlayerPos(playerid, g_Pos[playerid][0], g_Pos[playerid][1], g_Pos[playerid][2]);
			SendClientMessage(playerid, white,"[Anti G Bug] "cred"Do not abuse of the G car bug.");
		}
	}
	else if(newstate == PLAYER_STATE_ONFOOT) {
		g_EnterAnim{playerid} = false;
	}
	/*--------------------------------------------*/
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
        for (new i = 0; i<13; i++)
        {
        	GetPlayerWeaponData(playerid, i, DBWeapon[playerid][i], DBAmmo[playerid][i]);
        	SetPlayerArmedWeapon(playerid,0);
        }
	}
	if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT || oldstate == PLAYER_STATE_PASSENGER && newstate == PLAYER_STATE_ONFOOT)
	{
        for(new i=0;i<13;i++)
        {
            SetPlayerArmedWeapon(playerid, DBWeapon[playerid][i]);
        }
	}
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		if(IsBeingSpeced[playerid] == 1)
		{
	    	foreach(Player,i)
	    	{
	    		if(spectatorid[i] == playerid)
				{
					PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
				}
			}
		}
	}
	if(newstate == PLAYER_STATE_ONFOOT)
	{
		if(IsBeingSpeced[playerid] == 1)
		{
		    foreach(Player,i)
		    {
		    	if(spectatorid[i] == playerid)
				{
					PlayerSpectatePlayer(i, playerid);
				}
			}
		}
	}
	if(newstate == PLAYER_STATE_DRIVER && Team[playerid] == 1)
	{
		if(IsPlatVehicle(GetPlayerVehicleID(playerid)))
		{
		    if(PInfo[playerid][Premium] != 2)
		    {
		        new Float:x,Float:y,Float:z;
		        GetPlayerPos(playerid,x,y,z);
		        SetPlayerPos(playerid,x,y,z);
		        RemovePlayerFromVehicle(playerid);
		        SendClientMessage(playerid,white,"» "cred"Only platinium members can use this vehicle.");
		    }
		}
	}
	if(newstate == PLAYER_STATE_DRIVER && Team[playerid] == ZOMBIE)
	{
	    RemovePlayerFromVehicle(playerid);
	    SendClientMessage(playerid,white,"* "cred"Zombies can't drive.");
	}
	if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
	{
	    TextDrawHideForPlayer(playerid,FuelTD[playerid]);
		TextDrawHideForPlayer(playerid,OilTD[playerid]);
	}
	else if(newstate == PLAYER_STATE_DRIVER && oldstate == PLAYER_STATE_ONFOOT)
	{
	    TextDrawShowForPlayer(playerid,FuelTD[playerid]);
		TextDrawShowForPlayer(playerid,OilTD[playerid]);
		UpdateVehicleFuelAndOil(GetPlayerVehicleID(playerid));
		if(!IsVehicleStarted(GetPlayerVehicleID(playerid))) SendFMessage(playerid,white,"* "corange"This %s isn't started yet. You can press "cwhite"~k~~VEHICLE_FIREWEAPON~"corange" to start it "cwhite"*",GetVehicleName(GetPlayerVehicleID(playerid)));
	}
	return 1;
}

public OnPlayerEnterVehicle(playerid,vehicleid, ispassenger)
{
 	if(VehicleStarted[vehicleid] && !ispassenger) SendClientMessage(playerid, white, "* "cgreen"This vehicle is running.");
	if(ispassenger) { GetPlayerPos(playerid, g_Pos[playerid][0], g_Pos[playerid][1], g_Pos[playerid][2]); }
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerNPC(playerid)) return 1;
	else if((newkeys & KEY_NO) && !(oldkeys & KEY_NO))
	{
	    if(Team[playerid] == ZOMBIE) return 0;
        ShowInventory(playerid);
	}
	else if((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
	{
 		if(Team[playerid] == HUMAN) ShowPlayerHumanPerks(playerid);
		if(Team[playerid] == ZOMBIE) ShowPlayerZombiePerks(playerid);
	}
    else if(newkeys & KEY_CROUCH)
	{
		if(Team[playerid] == ZOMBIE)
		{
		    for(new p; p<sizeof pZPos; p++)
			{
			    if(IsPlayerInRangeOfPoint(playerid, 3.0, pZPos[p][0],pZPos[p][1],pZPos[p][2]))
				{
					ShowPlayerDialog(playerid, DIALOG_HIVETP, DIALOG_STYLE_LIST, "Hive TP",
						""cwhite"Grove Street\n"cwhite"Unity\n"cwhite"Los Santos Police Department\n"cwhite"Hospital\n"cwhite"Glen Park\n"cwhite"Market\n"cwhite"Vinewood\n"cwhite"Playa Costera\n"cwhite"Mulhegan\n"cwhite"Beach\n"cwhite"Hive", "[ V ]", "[ X ]");
				}
			}
		}
		else if(Team[playerid] == HUMAN)
		{
	    	new Float:obj_pos[3];
			GetObjectPos(airdropitem, obj_pos[0], obj_pos[1], obj_pos[2]);
			if(IsPlayerInRangeOfPoint(playerid, 2.5, obj_pos[0], obj_pos[1], obj_pos[2]))
			{
			    if(HasGettedDropItem{playerid} == true) return 1;
			    new rand = random(6);
				switch(rand)
				{
					case 0:
					{
					    RandomItemsAD{playerid} = 1;
					    ShowPlayerDialog(playerid, Airdropdialog, DIALOG_STYLE_MSGBOX, ""cwhite"Bag Items",
							"\t"cwhite"You have found the next items on this bag:\n\t\t"cgreen"2 mediums med kits.\n\t\t"cgreen"3 larges med kits.\n\t\t"cgreen"1 Dizzy Away.", "Take it", "");
					}
					case 1:
					{
					    RandomItemsAD{playerid} = 2;
					    ShowPlayerDialog(playerid, Airdropdialog, DIALOG_STYLE_MSGBOX, ""cwhite"Bag Items",
							"\t"cwhite"You have found the next items on this bag:\n\t\t"cgreen"1 large med kit.\n\t\t"cgreen"1 molotov guide.\n\t\t"cgreen"Some ammo for your weapons.", "Take it", "");
					}
					case 2:
					{
					    RandomItemsAD{playerid} = 3;
					    ShowPlayerDialog(playerid, Airdropdialog, DIALOG_STYLE_MSGBOX, ""cwhite"Bag Items",
							"\t"cwhite"You have found the next items on this bag:\n\t\t"cgreen"2 dizzy away.\n\t\t"cgreen"1 medium med kit.\n\t\t"cgreen"1 large med kit.", "Take it", "");
					}
					case 3:
					{
					    RandomItemsAD{playerid} = 4;
					    ShowPlayerDialog(playerid, Airdropdialog, DIALOG_STYLE_MSGBOX, ""cwhite"Bag Items",
							"\t"cwhite"You have found the next items on this bag:\n\t\t"cgreen"1 bouncing betty.\n\t\t"cgreen"1 medium med kit.\n\t\t"cgreen"Some ammo for your weapons.", "Take it", "");
					}
					case 4:
					{
					    RandomItemsAD{playerid} = 5;
					    ShowPlayerDialog(playerid, Airdropdialog, DIALOG_STYLE_MSGBOX, ""cwhite"Bag Items",
							"\t"cwhite"You have found the next items on this bag:\n\t\t"cgreen"5 smalls med kits.\n\t\t"cgreen"2 medium med kits.\n\t\t"cgreen"1 Dizzy Away.", "Take it", "");
					}
					case 5:
					{
					    RandomItemsAD{playerid} = 6;
					    ShowPlayerDialog(playerid, Airdropdialog, DIALOG_STYLE_MSGBOX, ""cwhite"Bag Items",
							"\t\t"cwhite"You have found the next items on this bag:\n\t\t"cgreen"2 larges med kits.\n\t\t"cgreen"1 small med kit.\n\t\t"cgreen"Some ammo for your weapons.", "Take it", "");
					}
				}
			}
		}
	}

 	if(CheckCrouch[playerid] == 1)
	{
        switch(WeaponID[playerid])
		{
            case 23..25, 27, 29..34, 41: {
                if((newkeys & KEY_CROUCH) && !((newkeys & KEY_FIRE) || (newkeys & KEY_HANDBRAKE)) && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK )
				{
                    if(Ammo[playerid][GetPlayerWeapon(playerid)] > GetPlayerAmmo(playerid))
					{
                    	CBugTimes[playerid] += 1;
                    	if(CBugTimes[playerid] >= 2) OnPlayerCBug(playerid);
  					}
                }
            }
        }
    }

    if(((newkeys & KEY_FIRE) && (newkeys & KEY_HANDBRAKE) && !((newkeys & KEY_SPRINT) || (newkeys & KEY_JUMP))) ||
    (newkeys & KEY_FIRE) && !((newkeys & KEY_SPRINT) || (newkeys & KEY_JUMP)) ||
    (NotMoving[playerid] && (newkeys & KEY_FIRE) && (newkeys & KEY_HANDBRAKE)) ||
    (NotMoving[playerid] && (newkeys & KEY_FIRE)) ||
    (newkeys & KEY_FIRE) && (oldkeys & KEY_CROUCH) && !((oldkeys & KEY_FIRE) || (newkeys & KEY_HANDBRAKE)) ||
    (oldkeys & KEY_FIRE) && (newkeys & KEY_CROUCH) && !((newkeys & KEY_FIRE) || (newkeys & KEY_HANDBRAKE)) )
	{
        SetTimerEx("CrouchCheck", 3000, 0, "d", playerid);
        CheckCrouch[playerid] = 1;
        WeaponID[playerid] = GetPlayerWeapon(playerid);
        Ammo[playerid][GetPlayerWeapon(playerid)] = GetPlayerAmmo(playerid);
    }
	if(Activated{playerid})
    {
        if(!IsPlayerInAnyVehicle(playerid))
        {
            if(newkeys & KEY_CROUCH)
            {
                if(Team[playerid] == 1 && PInfo[playerid][SPerk] == 10)
                {
                    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK && !Hidden{playerid})
                	{
						StealthMode(playerid);
                    }
                    else
                    {
                        RevealPlayer(playerid);
                    }
				}
            }
            if(Hidden{playerid})
            {
                if(newkeys & KEY_SPRINT || newkeys & KEY_JUMP || newkeys & KEY_ACTION || newkeys & KEY_FIRE)
	            {
	                if(Team[playerid] == 1)
	            	{
	                	RevealPlayer(playerid);
					}
	            }
            }
        }
    }
	if((newkeys & KEY_WALK) && (newkeys & KEY_CROUCH))
	{
	    if(PInfo[playerid][SPerk] == 9)
	    {
		    new string[70];
			if(CA_IsPlayerBlocked(playerid, 3.0, -1.0))
		    {
		        SendClientMessage(playerid, white, "* [ANTI BAIT-ABUSE] "cred"You can't drop the zombie bait here!");
			}
			else
			{
			    if(Team[playerid] == ZOMBIE) return 0;
		    	if(PInfo[playerid][ZombieBait] == 1) return SendClientMessage(playerid, white, "* "cred"You have to wait three minuts to use the zombie bait perk.");
			    DropItem(playerid, 2908, -0.01, 3.35, 0.0, 93.7, 120.0);
			    //GetPlayerPos(playerid, PInfo[playerid][ZX], PInfo[playerid][ZY], PInfo[playerid][ZZ]);
			    format(string,sizeof string,""cjam"%s(%i) has dropped some zombie bait",GetPName(playerid),playerid);
				SendNearMessage(playerid,white,string,20);
				PInfo[playerid][ZombieBait] = 1;
				SetTimerEx("StopBait", 15000, false, "i", playerid);
				SetTimerEx("UseBaitAgain", 150000, false, "i", playerid);
			}
		}
		else if(PInfo[playerid][SPerk] == 15)
		{
		    if(Team[playerid] == ZOMBIE) return 0;
		    new Float:x,Float:y,Float:z;
		    GetPlayerPos(playerid,x,y,z);
            RemovePlayerMapIcon(playerid,0);
            SetPlayerMapIcon(playerid,0,x,y,z,56,0,MAPICON_GLOBAL);
			DestroyObject(PInfo[playerid][Flare]);
			PInfo[playerid][Flare] = CreateObject(18728,x,y,z-1,0,0,0,200);
		}
	}
	if((newkeys & KEY_SPRINT) && (newkeys & KEY_CROUCH))
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 0;
		if(Team[playerid] == HUMAN && PInfo[playerid][SPerk] == 6)
		{
		    print("Player Perk = Burst run");
		    if(PInfo[playerid][CanBurst] == 0) return SendClientMessage(playerid,white,"» "cred"You are too tired to jump that far.");
      		new Float: X, Float: Y, Float: Z, Float: ROT;
			GetPlayerVelocity(playerid, X, Y, Z);
			GetPlayerFacingAngle(playerid, ROT);
			X += floatmul(floatsin(-ROT, degrees), 0.60);
			Y += floatmul(floatcos(-ROT, degrees), 0.60);
			SetPlayerVelocity(playerid, X, Y, Z+0.5);
			PInfo[playerid][CanBurst] = 0;
			print("Perk used - Jump done");
			PInfo[playerid][ClearBurst] = SetTimerEx("ClearBurstTimer",120000,false,"i",playerid);
			new string[64];
			format(string,sizeof string,""cjam"%s(%i) has gotten a burst of energy.",GetPName(playerid),playerid);
			SendNearMessage(playerid,white,string,20);
		}
		else if(Team[playerid] == ZOMBIE && PInfo[playerid][ZPerk] == 9)
		{
		    if(PInfo[playerid][CanBurst] == 0) return SendClientMessage(playerid,white,"» "cred"You are too tired to jump that far.");
      		new Float: X, Float: Y, Float: Z, Float: ROT;
			GetPlayerVelocity(playerid, X, Y, Z);
			GetPlayerFacingAngle(playerid, ROT);
			X += floatmul(floatsin(-ROT, degrees), 0.60);
			Y += floatmul(floatcos(-ROT, degrees), 0.60);
			SetPlayerVelocity(playerid, X, Y, Z+0.5);
			PInfo[playerid][CanBurst] = 0;
			PInfo[playerid][ClearBurst] = SetTimerEx("ClearBurstTimer",120000,false,"i",playerid);
			new string[64];
			format(string,sizeof string,""cjam"%s(%i) has gotten a burst of energy.",GetPName(playerid),playerid);
			SendNearMessage(playerid,white,string,20);
		}
	}
	if(newkeys & KEY_FIRE && PInfo[playerid][P_INTRO_OPTION] == INTRO_GUIDE)
	{
		if(PInfo[playerid][P_INTRO_GUIDE_OPTION]) PInfo[playerid][P_INTRO_GUIDE_OPTION] = false;
		else PInfo[playerid][P_INTRO_GUIDE_OPTION] = true;
		UpdatePlayerGuide(playerid);
		return 1;
	}
	else if(newkeys & KEY_HANDBRAKE && PInfo[playerid][P_INTRO_OPTION] == INTRO_GUIDE)
	{
		for(new i = 0; i != sizeof TD_INTRO_GUIDE; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_GUIDE[i]);
		PlayerTextDrawHide(playerid, PTD_INTRO_GUIDE[playerid]);
		for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_MAIN[i]);
		SelectTextDraw(playerid, 0x81BEF7CC);
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		PInfo[playerid][P_INTRO_OPTION] = INTRO_MAIN;
		SelectTextDraw(playerid, 0x81BEF7CC);
		return 1;
	}
	/*if (HOLDING(oldkeys, KEY_SPRINT) && PRESSED(newkeys, KEY_JUMP)){
		if(!IsPlayerInAnyVehicle(playerid) && Team[playerid] == 1)
    	{
       		BunnyHop[playerid] += 1;
         	SetTimer("TimerBunnyHop", 2000, false);
         	SetTimerEx("CheckBH", 4000, false, "d", playerid);
         	if(BunnyHop[playerid] >= 3) return SlapPlayer(playerid);
		}
    }*/
	if((newkeys & KEY_FIRE) && (oldkeys & KEY_WALK) || (newkeys & KEY_FIRE) && (oldkeys & KEY_WALK))
	{//2902
	    if(Team[playerid] == ZOMBIE) return 0;
	    if(IsPlayerInAnyVehicle(playerid)) return 0;
	    if(PInfo[playerid][Bettys] == 0) return 0;
	    new Float:x,Float:y,Float:z;
	    PInfo[playerid][Bettys]--;
	    PInfo[playerid][PlantedBettys]++;
	    GetPlayerPos(playerid,x,y,z);
	    switch(PInfo[playerid][PlantedBettys])
	    {
	        case 1: PInfo[playerid][BettyObj1] = CreateObject(2902,x,y,z-0.7,0,90,0,200),PInfo[playerid][BettyActive1] = 0,SetTimerEx("ActivateBetty",3000,false,"ii",playerid,1);
	        case 2: PInfo[playerid][BettyObj2] = CreateObject(2902,x,y,z-0.7,0,90,0,200),PInfo[playerid][BettyActive2] = 0,SetTimerEx("ActivateBetty",3000,false,"ii",playerid,2);
	        case 3: PInfo[playerid][BettyObj3] = CreateObject(2902,x,y,z-0.7,0,90,0,200),PInfo[playerid][BettyActive3] = 0,SetTimerEx("ActivateBetty",3000,false,"ii",playerid,3);
	    }
	    new string[90];
 		format(string,sizeof string,""cjam"%s has planted a bouncing betty.",GetPName(playerid));
		SendNearMessage(playerid,white,string,30);
		format(string,sizeof string,"~w~You now have ~r~~h~%i ~w~bouncing ~n~~w~Betty's left.",PInfo[playerid][Bettys]);
		GameTextForPlayer(playerid,string,3000,3);
	}
    else if(oldkeys & KEY_FIRE)
    {
        if(Team[playerid] == HUMAN)
        {
            if(GetPlayerWeapon(playerid) == 17)
            {
	            new Float:x,Float:y,Float:z;
				GetPlayerPos(playerid,x,y,z);
			 	for(new i=0; i < MAX_PLAYERS; i++)
	        	{
	        		if(IsPlayerInRangeOfPoint(i,30.0,x,y,z))
					{
	        			SetTimerEx("Flashbang",3000,0,"i",i);
					}
				}
			}
        }
    }
    //if(PRESSED(KEY_CROUCH))
	else if(newkeys & KEY_CROUCH)
	{
	    if(IsPlayerInAnyVehicle(playerid)) return 0;
	    if(PInfo[playerid][SPerk] == 11)
	    {
	        if(Team[playerid] == ZOMBIE) return 0;
			new Float:x,Float:y,Float:z,id;
			id = -1;
   			for(new i; i < MAX_VEHICLES;i++)
			{
				GetVehiclePos(i,x,y,z);
				if(IsPlayerInRangeOfPoint(playerid,3.0,x,y,z))
				{
					id = i;
					break;
				}
				else continue;
			}
			if(id == -1) return 0;
			new Float:health;
			GetVehicleHealth(id,health);
			if(health >= 500.0) return SendClientMessage(playerid,white,"» "cred"This vehicle doesn't need repairing!");
			TurnPlayerFaceToPos(playerid, x-270, y-270);
			ApplyAnimation(playerid, "CAR" , "Fixn_Car_Out" , 2.0 , 0 , 0 , 1 , 0 , 5000 , 1);
			new string[100];
		    format(string,sizeof string,""cjam"%s(%i) has tweaked his vehicle.",GetPName(playerid),playerid);
			SendNearMessage(playerid,white,string,20);
			SetVehicleHealth(id,health+250.0);
			SetTimerEx("ClearAnim",1500,false,"i",playerid);
		}
		if(PInfo[playerid][SPerk] == 16)
		{
		    if(Team[playerid] == ZOMBIE) return 0;
		    new Float:x,Float:y,Float:z,id;
			id = -1;
			for(new i; i < MAX_VEHICLES;i++)
			{
				GetVehiclePos(i,x,y,z);
				if(IsPlayerInRangeOfPoint(playerid,3.0,x,y,z))
				{
					id = i;
					break;
				}
				else continue;
			}
			if(id == -1) return 0;
			new Float:health;
			GetVehicleHealth(id,health);
			if(health >= 500.0) return SendClientMessage(playerid,white,"» "cred"This vehicle doesn't need repairing!");
			TurnPlayerFaceToPos(playerid, x-270, y-270);
			ApplyAnimation(playerid, "CAR" , "Fixn_Car_Out" , 2.0 , 0 , 0 , 1 , 0 , 5000 , 1);
			new string[100];
		    format(string,sizeof string,""cjam"%s(%i) has fixed his vehicle.",GetPName(playerid),playerid);
			SendNearMessage(playerid,white,string,20);
			RepairVehicle(id);
			SetVehicleHealth(id,1000.0);
			SetTimerEx("ClearAnim",2000,false,"i",playerid);
  		}
		if(Team[playerid] == HUMAN)
  		{
  		    if(Mission[playerid] == 1)
			{
				if(MissionPlace[playerid][1] == 1) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[playerid][0] == 1)
				    {
				        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[0][0],Locations[0][1],Locations[0][2]))
				        {
				            new rand = random(2);
							switch(rand)
							{
							    case 0: SendClientMessage(playerid,white,"* "corange"Now head over to Binco to get some cloth for your molotovs."), MissionPlace[playerid][0] = 3, MissionPlace[playerid][1] = 2,SetPlayerMapIcon(playerid,1,Locations[2][3],Locations[2][4],Locations[2][5],62,0,MAPICON_GLOBAL);
								case 1: SendClientMessage(playerid,white,"* "corange"Now head over to ZIP to get some cloth for your molotovs."), MissionPlace[playerid][0] = 4, MissionPlace[playerid][1] = 2,SetPlayerMapIcon(playerid,1,Locations[3][3],Locations[3][4],Locations[3][5],62,0,MAPICON_GLOBAL);
							}
							ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				        }
				    }
				    else if(MissionPlace[playerid][0] == 2)
				    {
				        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[1][0],Locations[1][1],Locations[1][2]))
				        {
				            new rand = random(2);
							switch(rand)
							{
				            	case 0: SendClientMessage(playerid,white,"* "corange"Now head over to Binco to get some cloth for your molotovs."), MissionPlace[playerid][0] = 3, MissionPlace[playerid][1] = 2,SetPlayerMapIcon(playerid,1,Locations[2][3],Locations[2][4],Locations[2][5],62,0,MAPICON_GLOBAL);
								case 1: SendClientMessage(playerid,white,"* "corange"Now head over to ZIP to get some cloth for your molotovs."), MissionPlace[playerid][0] = 4, MissionPlace[playerid][1] = 2,SetPlayerMapIcon(playerid,1,Locations[3][3],Locations[3][4],Locations[3][5],62,0,MAPICON_GLOBAL);
				        	}
				        	ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
       					}
				    }
				}
				if(MissionPlace[playerid][1] == 2) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[playerid][0] == 3)
				    {
                        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[2][0],Locations[2][1],Locations[2][2]))
				        {
				            new rand = random(2);
							switch(rand)
							{
							    case 0: SendClientMessage(playerid,white,"* "corange"Now head over to The Beach to get some inflamable liquid."), MissionPlace[playerid][0] = 5, MissionPlace[playerid][1] = 3,SetPlayerMapIcon(playerid,1,Locations[4][3],Locations[4][4],Locations[4][5],62,0,MAPICON_GLOBAL);
								case 1: SendClientMessage(playerid,white,"* "corange"Now head over to The Waste Industrial to get some inflamable liquid."), MissionPlace[playerid][0] = 6, MissionPlace[playerid][1] = 3,SetPlayerMapIcon(playerid,1,Locations[5][3],Locations[5][4],Locations[5][5],62,0,MAPICON_GLOBAL);
							}
							ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				        }
					}
					else if(MissionPlace[playerid][0] == 4)
				    {
                        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[3][0],Locations[3][1],Locations[3][2]))
				        {
				            new rand = random(2);
							switch(rand)
							{
							    case 0: SendClientMessage(playerid,white,"* "corange"Now head over to The Beach to get some inflamable liquid."), MissionPlace[playerid][0] = 5, MissionPlace[playerid][1] = 3,SetPlayerMapIcon(playerid,1,Locations[4][3],Locations[4][4],Locations[4][5],62,0,MAPICON_GLOBAL);
								case 1: SendClientMessage(playerid,white,"* "corange"Now head over to The Waste Industrial to get some inflamable liquid."), MissionPlace[playerid][0] = 6, MissionPlace[playerid][1] = 3,SetPlayerMapIcon(playerid,1,Locations[5][3],Locations[5][4],Locations[5][5],62,0,MAPICON_GLOBAL);
							}
							ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				        }
					}
				}
				if(MissionPlace[playerid][1] == 3) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[playerid][0] == 5)
				    {
                        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[4][0],Locations[4][1],Locations[4][2]))
				        {
				            ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				            SendClientMessage(playerid,white,"* "cblue"You have created 3 molotovs. Use them wisely!");
				            GivePlayerWeapon(playerid,18,3);
				            RemovePlayerMapIcon(playerid,1);
    						Mission[playerid] = 0;
				        }
					}
					else if(MissionPlace[playerid][0] == 6)
				    {
                        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[5][0],Locations[5][1],Locations[5][2]))
				        {
				            ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				            SendClientMessage(playerid,white,"* "cblue"You have created 3 molotovs. Use them wisely!");
				            GivePlayerWeapon(playerid,18,3);
				            RemovePlayerMapIcon(playerid,1);
    						Mission[playerid] = 0;
				        }
					}
				}
			}
			if(Mission[playerid] == 2)
			{
				if(MissionPlace[playerid][1] == 1) //From 1 to 3, to know if its string, ethanol or cans.
				{
				    if(MissionPlace[playerid][0] == 1)
				    {
				        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[0][0],Locations[0][1],Locations[0][2]))
				        {
				            new rand = random(2);
							switch(rand)
							{
							    case 0: SendClientMessage(playerid,white,"* "corange"Now head over to Binco to get some fuse for your betty's."), MissionPlace[playerid][0] = 3, MissionPlace[playerid][1] = 2,SetPlayerMapIcon(playerid,1,Locations[2][3],Locations[2][4],Locations[2][5],62,0,MAPICON_GLOBAL);
								case 1: SendClientMessage(playerid,white,"* "corange"Now head over to ZIP to get some fuse for your betty's."), MissionPlace[playerid][0] = 4, MissionPlace[playerid][1] = 2,SetPlayerMapIcon(playerid,1,Locations[3][3],Locations[3][4],Locations[3][5],62,0,MAPICON_GLOBAL);
							}
							ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				        }
				    }
				    else if(MissionPlace[playerid][0] == 2)
				    {
				        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[1][0],Locations[1][1],Locations[1][2]))
				        {
				            new rand = random(2);
							switch(rand)
							{
				            	case 0: SendClientMessage(playerid,white,"* "corange"Now head over to Binco to get some fuse for your betty's."), MissionPlace[playerid][0] = 3, MissionPlace[playerid][1] = 2,SetPlayerMapIcon(playerid,1,Locations[2][3],Locations[2][4],Locations[2][5],62,0,MAPICON_GLOBAL);
								case 1: SendClientMessage(playerid,white,"* "corange"Now head over to ZIP to get some fuse for your betty's."), MissionPlace[playerid][0] = 4, MissionPlace[playerid][1] = 2,SetPlayerMapIcon(playerid,1,Locations[3][3],Locations[3][4],Locations[3][5],62,0,MAPICON_GLOBAL);
				        	}
				        	ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
       					}
				    }
				}
				if(MissionPlace[playerid][1] == 2) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[playerid][0] == 3)
				    {
                        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[2][0],Locations[2][1],Locations[2][2]))
				        {
				            new rand = random(2);
							switch(rand)
							{
							    case 0: SendClientMessage(playerid,white,"* "corange"Now head over to The Beach to get some cans for your betty's."), MissionPlace[playerid][0] = 5, MissionPlace[playerid][1] = 3,SetPlayerMapIcon(playerid,1,Locations[4][3],Locations[4][4],Locations[4][5],62,0,MAPICON_GLOBAL);
								case 1: SendClientMessage(playerid,white,"* "corange"Now head over to The Waste Industrial to get cans for your betty's."), MissionPlace[playerid][0] = 6, MissionPlace[playerid][1] = 3,SetPlayerMapIcon(playerid,1,Locations[5][3],Locations[5][4],Locations[5][5],62,0,MAPICON_GLOBAL);
							}
							ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				        }
					}
					else if(MissionPlace[playerid][0] == 4)
				    {
                        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[3][0],Locations[3][1],Locations[3][2]))
				        {
				            new rand = random(2);
							switch(rand)
							{
							    case 0: SendClientMessage(playerid,white,"* "corange"Now head over to The Beach to get some cans for your betty's."), MissionPlace[playerid][0] = 5, MissionPlace[playerid][1] = 3,SetPlayerMapIcon(playerid,1,Locations[4][3],Locations[4][4],Locations[4][5],62,0,MAPICON_GLOBAL);
								case 1: SendClientMessage(playerid,white,"* "corange"Now head over to The Waste Industrial to get cans for your betty's."), MissionPlace[playerid][0] = 6, MissionPlace[playerid][1] = 3,SetPlayerMapIcon(playerid,1,Locations[5][3],Locations[5][4],Locations[5][5],62,0,MAPICON_GLOBAL);
							}
							ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				        }
					}
				}
				if(MissionPlace[playerid][1] == 3)
				{
				    if(MissionPlace[playerid][0] == 5)
				    {
                        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[4][0],Locations[4][1],Locations[4][2]))
				        {
				            ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				            SendClientMessage(playerid,white,"* "cblue"You have created 3 bouncing betty's. Use them wisely!");
				            RemovePlayerMapIcon(playerid,1);
    						Mission[playerid] = 0;
    						SendClientMessage(playerid,white,"* "cblue"Press WALK + LMB to place a bouncing betty");
    						PInfo[playerid][Bettys] = 3;
				        }
					}
					else if(MissionPlace[playerid][0] == 6)
				    {
                        if(IsPlayerInRangeOfPoint(playerid,3.0,Locations[5][0],Locations[5][1],Locations[5][2]))
				        {
				            ApplyAnimation(playerid,"KISSING","gift_give",3.0,0,1,1,1,2000,1);
				            SendClientMessage(playerid,white,"* "cblue"You have created 3 bouncing betty's. Use them wisely!");
				            RemovePlayerMapIcon(playerid,1);
    						Mission[playerid] = 0;
    						SendClientMessage(playerid,white,"* "cblue"Press WALK + LMB to place a bouncing betty");
    						PInfo[playerid][Bettys] = 3;
				        }
					}
				}
			}

	  		for(new jx; jx < sizeof(OilFuelSearch);jx++)
			{
			    if(GetTickCount() - PInfo[playerid][Searching] < 5000) return 0;
				if(IsPlayerInRangeOfPoint(playerid,2.0,OilFuelSearch[jx][0],OilFuelSearch[jx][1],OilFuelSearch[jx][2]))
				{
					PInfo[playerid][Searching] = GetTickCount();
					ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,1,0,0,0,0);
					SetTimerEx("ClearAnim",1500,false,"i",playerid);
					new rand2;
					rand2 = random(5);
					goto Random2;
					Random2:
					{
						switch(rand2)
						{
						    case 0:
						    {
		        				if(PInfo[playerid][SPerk] == 18)
								{
								    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
								    {
										goto Random;
										PInfo[playerid][LuckyCharm] = GetTickCount();
									}
									else
									{
									    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
									}
								}
						        else
									SendClientMessage(playerid,white,"* "cred"You haven't found anything");
						    }
						    case 1:
						    {
	         					new string[100];
							    format(string,sizeof string,""cjam"%s(%i) has found fuel.",GetPName(playerid),playerid);
								SendNearMessage(playerid,white,string,20);
						        AddItem(playerid, "Fuel", 1);
						    }
						    case 2:
						    {
		        				if(PInfo[playerid][SPerk] == 18)
								{
								    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
								    {
										goto Random;
										PInfo[playerid][LuckyCharm] = GetTickCount();
									}
									else
									{
									    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
									}
								}
						        else
									SendClientMessage(playerid,white,"* "cred"You haven't found anything");
						    }
						    case 3:
						    {
	         					new string[100];
							    format(string,sizeof string,""cjam"%s(%i) has found oil.",GetPName(playerid),playerid);
								SendNearMessage(playerid,white,string,20);
						        AddItem(playerid, "Oil", 1);
						    }
						    case 4:
						    {
		        				if(PInfo[playerid][SPerk] == 18)
								{
								    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
								    {
										goto Random;
										PInfo[playerid][LuckyCharm] = GetTickCount();
									}
									else
									{
									    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
									}
								}
						        else
									SendClientMessage(playerid,white,"* "cred"You haven't found anything");
						    }
						}
					}
				}
			}

	  		new id;
	  		id = -1;
	  		for(new j; j < sizeof(Searchplaces);j++)
			{
			    if(GetTickCount() - PInfo[playerid][Searching] < 5000) return 0;
			    if(IsPlayerInRangeOfPoint(playerid,2.0,Searchplaces[j][0],Searchplaces[j][1],Searchplaces[j][2]))
				{
				    id = j;
				    break;
				}
			}
			if(id == -1) return 0;
			else
			{
				PInfo[playerid][Searching] = GetTickCount();
				ApplyAnimation(playerid,"BOMBER","BOM_Plant",4.0,1,0,0,0,0);
				SetTimerEx("ClearAnim",1500,false,"i",playerid);
				new rand;
				rand = random(15);
				goto Random;
				Random:
				{
					switch(rand)
					{
					    case 0:
					    {
					        if(PInfo[playerid][SPerk] == 18)
							{
							    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
							    {
									goto Random;
									PInfo[playerid][LuckyCharm] = GetTickCount();
								}
								else
								{
								    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
								}
							}
					        else
								SendClientMessage(playerid,white,"* "cred"You haven't found anything");
					    }
					    case 1:
					    {
					        new larg_rand = random(2);
					        if(larg_rand == 0)
					        {
			                    new string[100];
							    format(string,sizeof string,""cjam"%s(%i) has found a large medical kit.",GetPName(playerid),playerid);
								SendNearMessage(playerid,white,string,20);
								AddItem(playerid,"Large Medical Kits",1);
							}
							else if(larg_rand == 1)
							{
							    if(PInfo[playerid][SPerk] == 18)
								{
								    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
								    {
										goto Random;
										PInfo[playerid][LuckyCharm] = GetTickCount();
									}
									else
									{
									    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
									}
								}
						        else
									SendClientMessage(playerid,white,"* "cred"You haven't found anything");
							}
					    }
					    case 2:
					    {
					        if(PInfo[playerid][SPerk] == 18)
							{
							    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
							    {
									goto Random;
									PInfo[playerid][LuckyCharm] = GetTickCount();
								}
								else
								{
								    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
								}
							}
					        else
								SendClientMessage(playerid,white,"* "cred"You haven't found anything");
					    }
					    case 3:
					    {
		                    new string[100];
						    format(string,sizeof string,""cjam"%s(%i) has found a medium medical kit.",GetPName(playerid),playerid);
							SendNearMessage(playerid,white,string,20);
							AddItem(playerid,"Medium Medical Kits",1);
					    }
					    case 4:
					    {
					        if(PInfo[playerid][SPerk] == 18)
							{
							    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
							    {
									goto Random;
									PInfo[playerid][LuckyCharm] = GetTickCount();
								}
								else
								{
								    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
								}
							}
					        else
								SendClientMessage(playerid,white,"* "cred"You haven't found anything");
					    }
					    case 5:
					    {
		                    new string[100];
						    format(string,sizeof string,""cjam"%s(%i) has found a small medical kit.",GetPName(playerid),playerid);
							SendNearMessage(playerid,white,string,20);
							AddItem(playerid,"Small Medical Kits",1);
					    }
					    case 6:
					    {
							if(PInfo[playerid][SPerk] == 18)
							{
							    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
							    {
									goto Random;
									PInfo[playerid][LuckyCharm] = GetTickCount();
								}
								else
								{
								    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
								}
							}
					        else
								SendClientMessage(playerid,white,"* "cred"You haven't found anything");
					    }
					    case 7:
					    {
		                    new string[100];
						    format(string,sizeof string,""cjam"%s(%i) has found a dizzy away pill.",GetPName(playerid),playerid);
							SendNearMessage(playerid,white,string,20);
							AddItem(playerid,"Dizzy Pills",1);
					    }
					    case 8:
					    {
					        if(PInfo[playerid][SPerk] == 18)
							{
							    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
							    {
									goto Random;
									PInfo[playerid][LuckyCharm] = GetTickCount();
								}
								else
								{
								    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
								}
							}
					        else
								SendClientMessage(playerid,white,"* "cred"You haven't found anything");
					    }
					    case 9:
					    {
		                    new string[100];
						    format(string,sizeof string,""cjam"%s(%i) has found a flashlight.",GetPName(playerid),playerid);
							SendNearMessage(playerid,white,string,20);
							AddItem(playerid,"Flashlight",1);
					    }
					    case 10:
					    {
					        if(PInfo[playerid][SPerk] == 18)
							{
							    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
							    {
									goto Random;
									PInfo[playerid][LuckyCharm] = GetTickCount();
								}
								else
								{
								    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
								}
							}
					        else
								SendClientMessage(playerid,white,"* "cred"You haven't found anything");
					    }
					    case 11:
					    {
					        if(PInfo[playerid][MolotovMission] == 1) return SendClientMessage(playerid,white,"* "cred"You haven't found anything");
		                    new string[100];
						    format(string,sizeof string,""cjam"%s(%i) has found a molotov mission guide.",GetPName(playerid),playerid);
							SendNearMessage(playerid,white,string,20);
							PInfo[playerid][MolotovMission] = 1;
							AddItem(playerid,"Molotovs Guide",1);
					    }
					    case 12:
					    {
					        if(PInfo[playerid][SPerk] == 18)
							{
							    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
							    {
									goto Random;
									PInfo[playerid][LuckyCharm] = GetTickCount();
								}
								else
								{
								    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
								}
							}
					        else
								SendClientMessage(playerid,white,"* "cred"You haven't found anything");
					    }
					    case 13:
					    {
							new rand2;
							rand2 = random(2);
							if(rand2 == 0) return SendClientMessage(playerid,white,"* "cred"You have found a broken dildo. (wortless)");
	                        new string[100];
							GivePlayerWeapon(playerid,10,1);
							format(string,sizeof string,""cjam"%s(%i) has found a purple dildo.",GetPName(playerid),playerid);
							SendNearMessage(playerid,white,string,20);
					    }
					    case 14:
					    {
					        if(PInfo[playerid][SPerk] == 18)
							{
							    if(GetTickCount() - PInfo[playerid][LuckyCharm] < 60000)
							    {
									goto Random;
									PInfo[playerid][LuckyCharm] = GetTickCount();
								}
								else
								{
								    SendClientMessage(playerid,white,"* "cred"You haven't found anything");
								}
							}
					        else
								SendClientMessage(playerid,white,"* "cred"You haven't found anything");
					    }
					    case 15:
					    {
					        if(PInfo[playerid][BettyMission] == 1) return SendClientMessage(playerid,white,"* "cred"You haven't found anything");
		                    new string[100];
						    format(string,sizeof string,""cjam"%s(%i) has found a boucing betty guide.",GetPName(playerid),playerid);
							SendNearMessage(playerid,white,string,20);
							PInfo[playerid][BettyMission] = 1;
							AddItem(playerid,"Bouncing Bettys Guide",1);
					    }
					}
				}
			}
		}
		if(Team[playerid] == ZOMBIE)
		{
		    if(PInfo[playerid][ZPerk] == 2)
		    {
		        if(PInfo[playerid][CanDig] == 0) return SendClientMessage(playerid,red,"You are to tired to dig!");
          		new id = -1;
		        id = GetClosestPlayer(playerid, 2000);
				if(Team[id] == ZOMBIE) return SendClientMessage(playerid,red,"You are to close to another zombie!");
				if(id == -1) return SendClientMessage(playerid,red,"It seems like the server is empty o.o'");
				if(PInfo[id][P_STATUS] != PS_SPAWNED) return 1;
				PInfo[playerid][CanDig] = 0;
				PInfo[playerid][DigTimer] = SetTimerEx("ResetDigVar",DIGTIME,false,"i",playerid);
				SetTimerEx("DigToPlayer",3000,false,"ii",playerid,id);
				ApplyAnimation(playerid,"WUZI","WUZI_GRND_CHK",0.5,0,0,0,1,3000,1);
		    }
		    if(PInfo[playerid][ZPerk] == 14)
		    {
		        if(PInfo[playerid][GodDig] == 1) return SendClientMessage(playerid,red,"You are to tired to dig!");
		        new id = -1,count = 0;
		        goto func;
		        func:
		        {
					new rand = random(PlayersConnected);
					if(Team[rand] == ZOMBIE)
					{
					    if(!IsPlayerConnected(rand) || IsPlayerNPC(rand)) goto func;
						if(count >= 1 || RoundEnded == 1 || PlayersConnected == 0) return SendClientMessage(playerid,white,"* "cred"Everyone is a zombie!");
						else
						{
						    count++;
							goto func;
						}
					}
					else id = rand;
		        }
				if(id == -1) return SendClientMessage(playerid,red,"It seems like the server is empty o.o'");
				if(PInfo[id][P_STATUS] != PS_SPAWNED) return 1;

				PInfo[playerid][GodDig] = 1;
				SetTimerEx("DigToPlayer",3000,false,"ii",playerid,id);
				ApplyAnimation(playerid,"WUZI","WUZI_GRND_CHK",0.5,0,0,0,1,3000,1);
				new string[120];
			 	format(string,sizeof string,"%s(%i) has god digged. Keep an eye on him. || 1 GOD DIG PER ROUND!",GetPName(playerid),playerid);
				SendAdminMessage(red,string);
		    }
		    if(PInfo[playerid][ZPerk] == 7)
		    {
		        if((GetTickCount() - PInfo[playerid][Allowedtovomit]) < VOMITTIME) return SendClientMessage(playerid,white,"* "cred"You don't have enough food in your stomach.");
                new Float:x,Float:y,Float:z;
		        GetPlayerPos(playerid,x,y,z);
		        PInfo[playerid][Vomitx] = x;
		        PInfo[playerid][Vomity] = y;
		        PInfo[playerid][Vomitz] = z;
		        ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);
		        SetTimerEx("VomitPlayer",3000, false, "i", playerid);
			}
			if(PInfo[playerid][ZPerk] == 12)
			{
			    if(PInfo[playerid][CanStomp] == 0) return SendClientMessage(playerid,white,"* "cred"You are tired to use so much force.");
				ApplyAnimation(playerid,"PED","FIGHTA_G",5.0,0,0,0,0,700,1);
				new Float:x,Float:y,Float:z;
				GetPlayerPos(playerid,x,y,z);
				PInfo[playerid][CanStomp] = 0;
				PInfo[playerid][StompTimer] = SetTimerEx("AllowedToStomp",120000,false,"i",playerid);
				for(new i; i < MAX_PLAYERS;i++)
				{
					if(!IsPlayerConnected(i)) continue;
					if(Team[i] == ZOMBIE) continue;
					if(IsPlayerInRangeOfPoint(i,15,x,y,z))
					{
					    if(IsPlayerNPC(i)) return 1;
					    TogglePlayerControllable(i,0);
						SetTimerEx("RemoveStomp",2500,false,"i",i);
						new string[90];
				 		format(string,sizeof string,""cjam"%s has received a powerfull misterious energy that froze him.",GetPName(i));
						SendNearMessage(playerid,white,string,30);
					}
				}
			}
			if(PInfo[playerid][ZPerk] == 15)
			{
			    if(PInfo[playerid][CanPop] == 0) return SendClientMessage(playerid, white,"* "cred"Please wait before you pop another set of tires.");
				new id = -1,Float:x,Float:y,Float:z;
				for(new i; i < MAX_VEHICLES;i++)
				{
				    GetVehiclePos(i,x,y,z);
				    if(IsPlayerInRangeOfPoint(playerid,5.0,x,y,z))
					{
						id = i;
						break;
					}
				}
				if(id == -1) return SendClientMessage(playerid,white,"** "cred"You are to far away from a car.");
				PInfo[playerid][CanPop] = 0;
				SetTimerEx("ClearAnim2",3000,false,"ii", playerid, id);
				SetTimerEx("PopAgain",120000,false,"i", playerid);
				ApplyAnimation(playerid,"RIFLE","RIFLE_crouchload",0.5,0,0,0,1,3000,1);
				new panels, doors, lights, tires;
				GetVehicleDamageStatus(id, panels, doors, lights, tires);
				UpdateVehicleDamageStatus(id, panels, doors, lights, 15);
				new string[90];
		 		format(string,sizeof string,""cjam"%s has chewed of the tires of a %s",GetPName(playerid),GetVehicleName(id));
				SendNearMessage(playerid,white,string,30);
			}
		}
	}
    else if(PRESSED(KEY_JUMP))
    {
        if(Team[playerid] == HUMAN)
        {
            if(PInfo[playerid][SPerk] != 14) return 0;
            if(GetTickCount() - PInfo[playerid][CanJump] < 8000) return 0;
            PInfo[playerid][CanJump] = GetTickCount();
            new Float:x,Float:y,Float:z;
            GetPlayerVelocity(playerid,x,y,z);
            SetPlayerVelocity(playerid,x,y,z+5);
            PInfo[playerid][CanJump] = GetTickCount();
			SetPlayerAttachedObject(playerid,1,18702,9,0.00,0.00,-1.63,0.0,0.0,0.0,1.00,1.00,1.00);//Left foot
			SetPlayerAttachedObject(playerid,2,18702,10,0.00,-0.09,-1.63,0.0,0.0,0.0,1.00,1.00,1.00);//Right foot
        }
        if(Team[playerid] == ZOMBIE)
        {
            if(PInfo[playerid][ZPerk] == 4)
            {
	            if(GetTickCount() - PInfo[playerid][CanJump] < 3500) return 0;
	            PInfo[playerid][CanJump] = GetTickCount();
	            new Float:x,Float:y,Float:z;
	            GetPlayerVelocity(playerid,x,y,z);
	            SetPlayerVelocity(playerid,x,y,z+5);
	            PInfo[playerid][CanJump] = GetTickCount();
            }
            else if(PInfo[playerid][ZPerk] == 11)
            {
                if(GetTickCount() - PInfo[playerid][CanJump] < 3500 && PInfo[playerid][Jumps] >= 2) return 0;
                if(GetTickCount() - PInfo[playerid][CanJump] > 3500 && PInfo[playerid][Jumps] >= 2) PInfo[playerid][Jumps] = 0;
	            PInfo[playerid][CanJump] = GetTickCount();
	            PInfo[playerid][Jumps]++;
	            new Float:x,Float:y,Float:z;
	            GetPlayerVelocity(playerid,x,y,z);
	            SetPlayerVelocity(playerid,x,y,z+5);
	            PInfo[playerid][CanJump] = GetTickCount();
            }
            else if(PInfo[playerid][ZPerk] == 16)
            {
                if(GetTickCount() - PInfo[playerid][CanJump] < 4300 && PInfo[playerid][Jumps] >= 4) return 0;
                if(GetTickCount() - PInfo[playerid][CanJump] > 4300 && PInfo[playerid][Jumps] >= 4) PInfo[playerid][Jumps] = 0;
	            PInfo[playerid][CanJump] = GetTickCount();
	            PInfo[playerid][Jumps]++;
	            new Float:x,Float:y,Float:z;
	            GetPlayerVelocity(playerid,x,y,z);
	            SetPlayerVelocity(playerid,x,y,z+5);
	            PInfo[playerid][CanJump] = GetTickCount();
            }
        }
    }

	//if(HOLDING(KEY_WALK) && HOLDING(KEY_CROUCH) || PRESSED(KEY_WALK) && PRESSED(KEY_CROUCH) || HOLDING(KEY_CROUCH) && HOLDING(KEY_WALK) || PRESSED(KEY_CROUCH) && PRESSED(KEY_WALK))
	else if((newkeys & KEY_SPRINT) && !(oldkeys & KEY_SPRINT))
	{
	    if(Team[playerid] == ZOMBIE)
	    {
            ApplyAnimation(playerid,"Muscular","MuscleSprint",4.1,1,1,1,1,1);
	    }
	    else if(Team[playerid] == HUMAN)
	    {
	        if(PInfo[playerid][SPerk] == 8)
	        {
	            if(PInfo[playerid][CanRun] == 0) return 0;
	            if(IsPlayerInAnyVehicle(playerid)) return 0;
	            ApplyAnimation(playerid,"Muscular","MuscleSprint",4.1,1,1,1,1,1);
				if(PInfo[playerid][RunTimerActivated] == 0) PInfo[playerid][RunTimer] = SetTimerEx("ResetRunVar",60000,false,"ii",playerid,1),PInfo[playerid][RunTimerActivated] = 1;
	        }
	        if(PInfo[playerid][Swimming] == 1)
	        {
	            new Float:health;
	            GetPlayerHealth(playerid,health);
				SetPlayerHealth(playerid,health-1);
				if(health <= 5)
				{
				    GetPlayerPos(playerid, ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2]);
			    	GetPlayerFacingAngle(playerid, ZPS[playerid][3]);
			    	SetSpawnInfo(playerid, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[playerid][0], ZPS[playerid][1], ZPS[playerid][2], ZPS[playerid][3], 0, 0, 0, 0, 0, 0);
				    //new rand = random(sizeof(RandomSpawnsZombie));
				    //SetSpawnInfo(playerid,0, ZombieSkins[random(sizeof(ZombieSkins))], RandomSpawnsZombie[rand][0], RandomSpawnsZombie[rand][1], RandomSpawnsZombie[rand][2],0,0,0,0,0,0,0);
			        SetPlayerSkin(playerid, ZombieSkins[random(sizeof(ZombieSkins))]);
			        InfectPlayer(playerid);
				}
			}
	    }
	}
	else if ((oldkeys & KEY_SPRINT) && !(newkeys & KEY_SPRINT))
	{
	    if(Team[playerid] == ZOMBIE)
	    {
	        ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
	    }
	    else if(Team[playerid] == HUMAN)
	    {
	        if(PInfo[playerid][SPerk] == 8)
	        {
	            if(PInfo[playerid][CanRun] == 0) return 0;
	            if(IsPlayerInAnyVehicle(playerid)) return 0;
     			ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
			}
	    }
	}
	else if(PRESSED(KEY_FIRE))
	{
	    if(PInfo[playerid][StartCar] == 1) return 0;
	    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 0;
	    if(IsVehicleStarted(GetPlayerVehicleID(playerid))) return 0;
		if(Fuel[GetPlayerVehicleID(playerid)] <= 0) return SendClientMessage(playerid,white,"* "cred"This vehicle has no fuel!");
		if(Oil[GetPlayerVehicleID(playerid)] <= 0) return SendClientMessage(playerid,white,"* "cred"This vehicle has no oil!");
		new Float:health;
		GetVehicleHealth(GetPlayerVehicleID(playerid),health);
		if(health <= 350) return SendClientMessage(playerid,white,"* "cred"This vehicle is to damaged to start!");
		SetTimerEx("Startvehicle",2300,false,"i",playerid);
		new string[64];
		format(string,sizeof string,""cjam"%s(%i) has tried to start his car...",GetPName(playerid),playerid);
		SendNearMessage(playerid,white,string,20);
		PInfo[playerid][StartCar] = 1;
	}
	else if(PRESSED(KEY_HANDBRAKE))//Aim Key
	{
	    if(Team[playerid] != ZOMBIE) return 0;
	    if(PInfo[playerid][CanBite] == 0) return 0;
        if(PInfo[playerid][ZPerk] == 8)
		{
		    if(IsPlayerInAnyVehicle(playerid)) return 1;
		    if(GetTickCount() - PInfo[playerid][Canscream] < 6000) return 1;
		    for(new i, f = MAX_PLAYERS; i < f; i++)
		    {
      		    if(i == playerid) continue;
			    if(PInfo[i][Dead] == 1) continue;
			    if(Team[i] == ZOMBIE) continue;
			    if(IsPlayerNPC(i)) continue;
		        //if(IsPlayerInAnyVehicle(i)) continue;
		        if(PInfo[i][Rank] <= 5) continue;
		        new Float:x,Float:y,Float:z;
		    	GetPlayerPos(playerid,x,y,z);
		        if(IsPlayerInRangeOfPoint(i, 15.0,x,y,z))
		        {
		            if(IsPlayerFacingPlayer(playerid, i, 70))
		            {
						//SetPlayerForwardVelocity(i, -0.4, 0.1);

						new Float:a;
						GetPlayerVelocity(i,x,y,z);
						GetPlayerFacingAngle(playerid,a);
						x += ( 0.4 * floatsin( -a, degrees ) );
						y += ( 0.4 * floatcos( -a, degrees ) );
						SetPlayerVelocity(i,x,y,z+0.20);

      					new Float:Health;
			  			GetPlayerHealth(i,Health);
		 				MakeHealthEven(i,Health);
						if(Health <= 10)
							MakeProperDamage(i);
						else
			  				SetPlayerHealth(i,Health-5);

						ApplyAnimation(i, "FIGHT_E", "HIT_FIGHTKICK_B", 4.1,0,0,0,0,0);
		            }

		            new Float:HP;
		  			GetPlayerHealth(i,HP);

				 	if(HP <= 5)
				 	{
				 	    GetPlayerPos(i, ZPS[i][0], ZPS[i][1], ZPS[i][2]);
			    		GetPlayerFacingAngle(i, ZPS[i][3]);
			    		SetSpawnInfo(i, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[i][0], ZPS[i][1], ZPS[i][2], ZPS[i][3], 0, 0, 0, 0, 0, 0);
				 	    InfectPlayer(i);
				 	    PInfo[i][JustInfected] = 1;
				 	    //PInfo[playerid][Infects]++;
				 	    PInfo[i][Deaths]++;
				 	    PInfo[playerid][Screams]++;

						PInfo[playerid][InfectsRound]++;

					    GivePlayerXP(playerid);
					    CheckRankup(playerid);

					    new string2[45];
						if(PInfo[i][Premium] == 1) {
							format(string2,sizeof string2,""cgold"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]); }
						else if(PInfo[i][Premium] == 2) {
						    format(string2,sizeof string2,""cplat"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]); }
						else {
						    format(string2,sizeof string2,""cpurple"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]); }
				 	}
		        }
				if(PInfo[i][Infected] == 0) PInfo[i][Infected] = 1;
   			}
            ApplyAnimation(playerid,"RIOT","RIOT_shout",4.1,0,0,0,0,0);
            SetTimerEx("ClearAnim2",600,false,"i",playerid);
            PInfo[playerid][Canscream] = GetTickCount();
  		}
  		else if(PInfo[playerid][ZPerk] == 19)
		{
		    if(IsPlayerInAnyVehicle(playerid)) return 1;
		    if(GetTickCount() - PInfo[playerid][Canscream] < 8000) return 1;
		    for(new i, f = MAX_PLAYERS; i < f; i++)
		    {
		        if(!IsPlayerConnected(i)) continue;
      		    if(i == playerid) continue;
      		    if(IsPlayerNPC(i)) continue;
			    if(PInfo[i][Dead] == 1) continue;
			    if(Team[i] == ZOMBIE) continue;
			    if(PInfo[i][Rank] <= 5) continue;
       			new Float:x,Float:y,Float:z;
		    	GetPlayerPos(playerid,x,y,z);
		        if(IsPlayerInRangeOfPoint(i,20.0, x, y, z))
		        {
		            if(IsPlayerFacingPlayer(playerid, i, 70))
		            {
		                if(!IsPlayerInAnyVehicle(i))
		                {
							//SetPlayerForwardVelocity(i, -0.4, 0.1);

							new Float:a;
							GetPlayerVelocity(i,x,y,z);
							GetPlayerFacingAngle(playerid,a);
							x += ( 0.4 * floatsin( -a, degrees ) );
							y += ( 0.4 * floatcos( -a, degrees ) );
							SetPlayerVelocity(i,x,y,z+0.20);

							new Float:Health;
				  			GetPlayerHealth(i,Health);
							MakeHealthEven(i,Health);
				  			if(Health <= 10.0)
			  					MakeProperDamage(i);
							else
				  				SetPlayerHealth(i,Health-8.0);

							ApplyAnimation(i, "FIGHT_E", "HIT_FIGHTKICK_B", 4.1,0,0,0,0,0);

       						new Float:HP;
				  			GetPlayerHealth(i,HP);

						 	if(HP <= 5)
						 	{
						 	    GetPlayerPos(i, ZPS[i][0], ZPS[i][1], ZPS[i][2]);
					    		GetPlayerFacingAngle(i, ZPS[i][3]);
					    		SetSpawnInfo(i, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[i][0], ZPS[i][1], ZPS[i][2], ZPS[i][3], 0, 0, 0, 0, 0, 0);
						 	    InfectPlayer(i);
						 	    PInfo[i][JustInfected] = 1;
						 	    //PInfo[playerid][Infects]++;
						 	    PInfo[i][Deaths]++;
						 	    PInfo[playerid][Screams]++;
							    GivePlayerXP(playerid);
							    CheckRankup(playerid);
						 	}
						}
						else
						{
						    new Float:Health;
				  			GetPlayerHealth(i,Health);
							MakeHealthEven(i,Health);
				  			if(Health <= 10.0)
			  					MakeProperDamage(i);
							else
				  				SetPlayerHealth(i,Health-8.0);

						    SetVehicleAngularVelocity(GetPlayerVehicleID(i), 0, 0, 0.2);

          					new Float:HP;
				  			GetPlayerHealth(i,HP);

						 	if(HP <= 5)
						 	{
						 	    GetPlayerPos(i, ZPS[i][0], ZPS[i][1], ZPS[i][2]);
					    		GetPlayerFacingAngle(i, ZPS[i][3]);
					    		SetSpawnInfo(i, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[i][0], ZPS[i][1], ZPS[i][2], ZPS[i][3], 0, 0, 0, 0, 0, 0);
						 	    InfectPlayer(i);
						 	    PInfo[i][JustInfected] = 1;
						 	    //PInfo[playerid][Infects]++;
								PInfo[playerid][InfectsRound]++;
						 	    PInfo[i][Deaths]++;
						 	    PInfo[playerid][Screams]++;
							    GivePlayerXP(playerid);
							    CheckRankup(playerid);
						 	}
						}
		            }
		        }
				if(PInfo[i][Infected] == 0) PInfo[i][Infected] = 1;
   			}
            ApplyAnimation(playerid,"RIOT","RIOT_shout", 3, 1, 1, 1, 1, 600, 1);
            SetTimerEx("ClearAnim2",600,false,"i",playerid);
            PInfo[playerid][Canscream] = GetTickCount();
  		}
  		else
  		{
  		    new Float:x,Float:y,Float:z;
		    GetPlayerPos(playerid,x,y,z);
		    new i;
		    i = -1;
		    for(new j, f = MAX_PLAYERS; j < f; j++)
		    {
		        if(j == playerid) continue;
		        if(PInfo[j][Dead] == 1) continue;
                if(IsPlayerNPC(i)) continue;
		        if(Team[j] == ZOMBIE) continue;
		        if(IsPlayerInRangeOfPoint(j,1.2,x,y,z))
		        {
		            i = j;
		            break;
		        }
  			}
  			/*if(GetTimerCMD(playerid, 1))
			{
				return true;
	        }
	        SetTimerCMD(playerid, 1, 1);*/
  			new Float:Health;
            GetPlayerHealth(i,Health);
            MakeHealthEven(i,Health);
  			DamagePlayer(playerid,i);
		 	if(PInfo[playerid][ZPerk] == 3)
			{
				GetPlayerHealth(playerid,Health);
				if(Health >= 100.0) SetPlayerHealth(playerid,100.0);
				else SetPlayerHealth(playerid,Health+6);
			}
			else if(PInfo[playerid][ZPerk] == 13)
			{
				GetPlayerHealth(playerid,Health);
				if(Health >= 100.0) SetPlayerHealth(playerid,100.0);
				else SetPlayerHealth(playerid,Health+10);
			}
			else
			{
				if(PInfo[playerid][ZPerk] != 18)
				{
					GetPlayerHealth(playerid,Health);
					if(Health >= 100.0) SetPlayerHealth(playerid,100.0);
					SetPlayerHealth(playerid,Health+3);
				}
			}

			GetPlayerHealth(playerid,Health);
			if(Health >= 100.0) SetPlayerHealth(playerid,100.0);

            PlayNearSound(i,1136);
         	SetTimerEx("CantBite",500,0,"i",playerid);
       		PInfo[playerid][CanBite] = 0;
		    PlayerPlaySound(i, 1136, 0.0, 0.0, 0.0);
			PlayerPlaySound(playerid, 1136, 0.0, 0.0, 0.0);
			PInfo[playerid][Bites]++;
			PInfo[i][Lastbite] = playerid;
			if(PInfo[i][Infected] == 0) PInfo[i][Infected] = 1;
			//ApplyAnimation(playerid,"WAYFARER","WF_FWD",1.2,1,1,1,0,400,1);
			ApplyAnimation(i,"PED","DAM_armR_frmFT",4.1,0,0,0,0,0);
			ApplyAnimation(playerid,"BIKED","BIKEd_Fwd",4.1,0,0,0,0,0);

            GetPlayerHealth(i,Health);
		    MakeHealthEven(i,Health);
			if(Health <= 3.0)
			{
			    GetPlayerPos(i, ZPS[i][0], ZPS[i][1], ZPS[i][2]);
			    GetPlayerFacingAngle(i, ZPS[i][3]);
			    //SetSpawnInfo(i, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[i][0], ZPS[i][1], ZPS[i][2], ZPS[i][3], 0, 0, 0, 0, 0, 0);
			    InfectPlayer(i);
			    PInfo[i][JustInfected] = 1;
			    PInfo[playerid][Infects]++;
			    PInfo[i][Deaths]++;
			    //GivePlayerXP(playerid);
                CheckRankup(playerid);
			}
			if(PInfo[playerid][ZPerk] == 10)
			{
				new rand = random(3);
				if(rand == 1)
					ApplyAnimation(i,"BEACH","SitnWait_loop_W",3,0,0,0,0,1500,1);
			}
  		}
	}

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    InventoryOnDialogResponse(playerid, dialogid, response, inputtext);
    switch(dialogid)
    {
        case Empty: return true;
        case List:
        {
            CurrentObject{playerid} = listitem;

            new
                string[129];

			format(string, sizeof(string), "You selected {94ED40}%s{FFFFFF} (Model: {94ED40}%d{FFFFFF}) as your cover. press {94ED40}C (Crouch)", ObjectInfo[listitem][o_n], ObjectInfo[listitem][o_id]);
            return SendClientMessage(playerid, ~1, string), true;
        }
    }
    if(dialogid == Airdropdialog)
    {
        if(response)
        {
            TimesGettedAirDrop++;
			if(TimesGettedAirDrop == MAX_GET_AIRDROP)
			{
			    DestroyObject(airdropitem);
			    RemovePlayerMapIcon(playerid, 50);
			    TimesGettedAirDrop = 0;
			    return 1;
			}
            new weapons[13][2], string[128];
            if(RandomItemsAD{playerid} == 1)
            {
                HasGettedDropItem{playerid} = true;
		     	AddItem(playerid,"Medium Medical Kits",2);
			    AddItem(playerid,"Large Medical Kits",3);
			    AddItem(playerid,"Dizzy Pills",1);

		    	format(string,sizeof(string),""cjam"» %s took the items from the airdrop.",GetPName(playerid));
				SendNearMessage(playerid,white,string,30);
            }
            if(RandomItemsAD{playerid} == 2)
            {
                HasGettedDropItem{playerid} = true;
                AddItem(playerid,"Molotovs Guide",1);
			    AddItem(playerid,"Large Medical Kits",1);


				for(new f = 0; f < 13; f++)
				{
				    GetPlayerWeaponData(playerid, f, weapons[f][0], weapons[f][1]);
				}

				if(weapons[2][0] == 22) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,22,20);}else{GivePlayerWeapon(playerid,22,50); }
				if(weapons[2][0] == 23) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,23,20);}else{GivePlayerWeapon(playerid,23,50); }
				if(weapons[2][0] == 24) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,24,20);}else{GivePlayerWeapon(playerid,24,50); }
				if(weapons[3][0] == 25) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,25,30);}else{GivePlayerWeapon(playerid,25,20); }
				if(weapons[3][0] == 26) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,26,30);}else{GivePlayerWeapon(playerid,26,30); }
				if(weapons[3][0] == 27) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,27,30);}else{GivePlayerWeapon(playerid,27,30); }
				if(weapons[4][0] == 28) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,28,120);}else{GivePlayerWeapon(playerid,28,120); }
				if(weapons[4][0] == 32) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,32,120);}else{GivePlayerWeapon(playerid,32,120); }
				if(weapons[6][0] == 33) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,33,30);}else{GivePlayerWeapon(playerid,33,30); }

				format(string,sizeof(string),""cjam"» %s took the items from the airdrop.",GetPName(playerid));
				SendNearMessage(playerid,white,string,30);
            }
            if(RandomItemsAD{playerid} == 3)
            {
                HasGettedDropItem{playerid} = true;
		     	AddItem(playerid,"Medium Medical Kits",1);
			    AddItem(playerid,"Large Medical Kits",1);
			    AddItem(playerid,"Dizzy Pills",2);

			    format(string,sizeof(string),""cjam"» %s took the items from the airdrop.",GetPName(playerid));
				SendNearMessage(playerid,white,string,30);
            }
            if(RandomItemsAD{playerid} == 4)
            {
                HasGettedDropItem{playerid} = true;
                AddItem(playerid,"Bouncing Bettys Guide",1);
		     	AddItem(playerid,"Medium Medical Kits",1);

		     	format(string,sizeof(string),""cjam"» %s took the items from the airdrop.",GetPName(playerid));
				SendNearMessage(playerid,white,string,30);

            }
            if(RandomItemsAD{playerid} == 5)
            {
                HasGettedDropItem{playerid} = true;
            	AddItem(playerid,"Small Medical Kits",5);
		     	AddItem(playerid,"Medium Medical Kits",2);
			    AddItem(playerid,"Dizzy Pills",1);

			    format(string,sizeof(string),""cjam"» %s took the items from the airdrop.",GetPName(playerid));
				SendNearMessage(playerid,white,string,30);
            }
            if(RandomItemsAD{playerid} == 6)
            {
                HasGettedDropItem{playerid} = true;
                AddItem(playerid,"Small Medical Kits",1);
			    AddItem(playerid,"Large Medical Kits",2);

				for(new f = 0; f < 13; f++)
				{
				    GetPlayerWeaponData(playerid, f, weapons[f][0], weapons[f][1]);
				}

				if(weapons[2][0] == 22) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,22,20);}else{GivePlayerWeapon(playerid,22,50); }
				if(weapons[2][0] == 23) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,23,20);}else{GivePlayerWeapon(playerid,23,50); }
				if(weapons[2][0] == 24) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,24,20);}else{GivePlayerWeapon(playerid,24,50); }
				if(weapons[3][0] == 25) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,25,30);}else{GivePlayerWeapon(playerid,25,20); }
				if(weapons[3][0] == 26) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,26,30);}else{GivePlayerWeapon(playerid,26,30); }
				if(weapons[3][0] == 27) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,27,30);}else{GivePlayerWeapon(playerid,27,30); }
				if(weapons[4][0] == 28) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,28,120);}else{GivePlayerWeapon(playerid,28,120); }
				if(weapons[4][0] == 32) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,32,120);}else{GivePlayerWeapon(playerid,32,120); }
				if(weapons[6][0] == 33) if(PInfo[playerid][SPerk] == 12) { GivePlayerWeapon(playerid,33,30);}else{GivePlayerWeapon(playerid,33,30); }

				format(string,sizeof(string),""cjam"» %s took the items from the airdrop.",GetPName(playerid));
				SendNearMessage(playerid,white,string,30);
            }
        }
		else
		{
            HasGettedDropItem{playerid} = true;
            RandomItemsAD{playerid} = 0;
            SendClientMessage(playerid, white, "* "cred"Now you have to wait until the next bag is dropped.");
        }
    }
    if(dialogid == DIALOG_HIVETP)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0:
			{
				SetPlayerPos(playerid, 2606.136230, -1463.581054, 19.009654);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Groove
			}
            case 1:
			{
				SetPlayerPos(playerid, 1694.141113, -1971.765380, 8.824961);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Unity
			}
            case 2:
			{
				SetPlayerPos(playerid, 1547.274780, -1636.830566, 6.218750);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // LSPD
			}
            case 3:
            {
				SetPlayerPos(playerid, 1294.354125, -1249.394653, 13.600000);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Hospital
			}
            case 4:
            {
				SetPlayerPos(playerid, 1908.839355, -1318.581298, 14.199999);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Glen
			}
            case 5:
            {
				SetPlayerPos(playerid, 831.413146, -1390.246582, -0.553125);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Market
			}
            case 6:
            {
				SetPlayerPos(playerid, 998.767272, -897.245483, 42.300121);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Vinewood
			}
            case 7:
            {
				SetPlayerPos(playerid, 2795.812744, -1176.926879, 28.915470);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Playa Costera
			}
            case 8:
            {
				SetPlayerPos(playerid, 1618.350830, -993.629333, 24.067668);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Mulhegan
			}
            case 9:
            {
				SetPlayerPos(playerid, 358.485534, -1755.051025, 5.524650);
				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0); // Beach
			}
            case 10:
            {
                new rand = random(sizeof(RandomSpawnsZombie));
				SetPlayerPos(playerid, RandomSpawnsZombie[rand][0], RandomSpawnsZombie[rand][1], RandomSpawnsZombie[rand][2]); // Hive
				TogglePlayerControllable(playerid, false);
				GameTextForPlayer(playerid, "~w~Loading objects, wait..", 4000, 4);
				SetTimerEx("ObjectsLoaded", 4000, 0, "i", playerid);
				SetPlayerWeather(playerid, 9);
	    		SetPlayerTime(playerid, 6, 0);
			}
		}
    }
    if(dialogid == Nozombieperkdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 0;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Hardbitedialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 1;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Diggerdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 2;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Refreshingbitedialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 3;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Jumperdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 4;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Hidemodedialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 5;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Hardpunchdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 6;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Vomiterdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 7;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Screamerdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 8;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == ZBurstrundialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 9;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Stingerbitedialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 10;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Bigjumperdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 11;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Stompdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 12;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Refreshingbitedialog2)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 13;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Goddigdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 14;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Poppingtiresdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 15;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Higherjumperdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 16;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Repellentdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 17;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Ravagingbitedialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 18;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Superscreamdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 19;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
	if(dialogid == Boomerdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][ZPerk] = 20;
		SendClientMessage(playerid,orange,"You have successfully changed your zombie perk.");
	}
    if(dialogid == Zombieperksdialog)
    {
        if(!response) return 0;
        if(listitem == 0)
        {
			ShowPlayerDialog(playerid,Nozombieperkdialog,0,"No zombie perk",""cwhite"This will set your zombie perk variable to none.","Set","Close");
        }
        if(listitem == 1)
        {
			ShowPlayerDialog(playerid,Hardbitedialog,0,"Hard Bite",""cwhite"With this perk, when you bite, you do more damage to humans.","Set","Close");
        }
        if(listitem == 2)
        {
			ShowPlayerDialog(playerid,Diggerdialog,0,"Digger",""cwhite"With this perk, you are allowed to dig to the closest human.","Set","Close");
        }
        if(listitem == 3)
        {
			ShowPlayerDialog(playerid,Refreshingbitedialog,0,"Refreshing Bite",""cwhite"With this perk, when you bite a human, you get +6HP.","Set","Close");
        }
        if(listitem == 4)
        {
			ShowPlayerDialog(playerid,Jumperdialog,0,"Jumper",""cwhite"With this perk, you are able to jump, higher than normal.","Set","Close");
        }
        if(listitem == 5)
        {
			ShowPlayerDialog(playerid,Hidemodedialog,0,"Hide Mode",""cwhite"With this perk, you are able to hide yourself in vehicles using /hide.","Set","Close");
        }
        if(listitem == 6)
        {
			ShowPlayerDialog(playerid,Hardpunchdialog,0,"Hard Punch",""cwhite"This perk is for, when you punch a human, he gets a critical hit.","Set","Close");
        }
        if(listitem == 7)
        {
			ShowPlayerDialog(playerid,Vomiterdialog,0,"Vomiter",""cwhite"With this perk, when you press -"cred"CROUCH"cwhite"- you vomit, and humans get health damage.","Set","Close");
        }
        if(listitem == 8)
        {
			ShowPlayerDialog(playerid,Screamerdialog,0,"Screamer",""cwhite"With this perk, when you press -"cred"RIGHT MOUSE BUTTON"cwhite"- you scream. So humans, and get affected by listening to it.\n"cred"Only works with rank 5+ players.","Set","Close");
        }
        if(listitem == 9)
        {
			ShowPlayerDialog(playerid,ZBurstrundialog,0,"Burst run",""cwhite"This perk, allows you to get a burst run of energy by pressing -"cred"SPRINT + CROUCH"cwhite"-","Set","Close");
        }
        if(listitem == 10)
        {
			ShowPlayerDialog(playerid,Stingerbitedialog,0,"Stinger bite",""cwhite"This perk, is to put a human down, when you bite him. "cgrey"You have 1 in 3 chances.","Set","Close");
        }
        if(listitem == 11)
        {
			ShowPlayerDialog(playerid,Bigjumperdialog,0,"Big jumper",""cwhite"With this perk, you are able to jump twice in a row.","Set","Close");
        }
        if(listitem == 12)
        {
			ShowPlayerDialog(playerid,Stompdialog,0,"Stomp",""cwhite"With this perk enabled, you are able to send a mini but powerfull earthquake. \nAny survivor around you will get affected with it. -"cred"CROUCH"cwhite"- \n"cred"Note: Cool down of 2 minutes.","Set","Close");
        }
        if(listitem == 13)
        {
			ShowPlayerDialog(playerid,Refreshingbitedialog2,0,"More Refreshing Bite",""cwhite"With this perk, when you bite a human, you get +10HP.","Set","Close");
        }
        if(listitem == 14)
        {
			ShowPlayerDialog(playerid,Goddigdialog,0,"God dig",""cwhite"With this perk, you are allowed to dig to the closest human, even tho you have a zombie in your way.","Set","Close");
        }
        if(listitem == 15)
        {
			ShowPlayerDialog(playerid,Poppingtiresdialog,0,"Popping Tires",""cwhite"With this perk, you are allowed to pop vehicle tires, by pressing -"cred"CROUCH"cwhite"-.","Set","Close");
        }
        if(listitem == 16)
        {
			ShowPlayerDialog(playerid,Higherjumperdialog,0,"Higher Jumper",""cwhite"With this perk, you are able to jumper higher than before. You can jump 4 times in mid air.","Set","Close");
        }
        if(listitem == 17)
        {
			ShowPlayerDialog(playerid,Repellentdialog,0,"Repellent",""cwhite"With this perk, you are imune to all zombie baits. (You don't get affected)","Set","Close");
        }
        if(listitem == 18)
        {
			ShowPlayerDialog(playerid,Ravagingbitedialog,0,"Ravaging Bite",""cwhite"Ravaging bite is the most powerfull zombie bite perk at the moment \nWhen you bite someone, you do the same damage with Hard Bite and you get healed the same amount as Refreshing bite. \n"cred"Note: -10HP of damage on a victim and +6HP to you.","Set","Close");
        }
        if(listitem == 19)
        {
			ShowPlayerDialog(playerid,Superscreamdialog,0,"Super Scream",""cwhite"With this perk, you are able to shout exactly as the perk Screamer, but with this one, vehicles get affected.\n"cred"Only works with rank 5+ players.","Set","Close");
        }
        if(listitem == 20)
        {
			ShowPlayerDialog(playerid,Boomerdialog,0,"Boomer",""cwhite"With this perk, when you die you generate a small explosion.","Set","Close");
        }
    }


    if(dialogid == Noperkdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 0;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
    if(dialogid == Extramedsdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 1;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Extrafueldialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 2;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Extraoildialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 3;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Lessbitedialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 5;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
    if(dialogid == Flashbangsdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 4;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Burstdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 6;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Medicdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 7;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Morestaminadialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 8;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Zombiebaitdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 9;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Firemodedialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 20;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Mechanicdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 11;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Extraammodialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 12;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Fielddoctordialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 13;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Rocketbootsdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 14;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Homingbeacondialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 15;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Mastermechanicdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 16;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Flameroundsdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 17;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Luckycharmdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 18;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Grenadesdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 19;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
	}
	if(dialogid == Stealthdialog)
	{
	    if(!response) return 0;
		PInfo[playerid][SPerk] = 10;
		SendClientMessage(playerid,orange,"You have successfully changed your survivor perk.");
		SendClientMessage(playerid, 0xFFFFFFFF, "GUIDE: Use /hideo to choose an object to hide.");
 		SendClientMessage(playerid, 0xFFFFFFFF, "GUIDE: To use this perk, after using /hideo press \"C\" to hide.");
 		Activated{playerid} = true;
	}
	if(dialogid == Humanperksdialog)
	{
	    if(!response) return 0;
	    if(listitem == 0)
	    {
	        ShowPlayerDialog(playerid,Noperkdialog,0,"None",""cwhite"This is to set your perk variable to none.","Set","Cancel");
	    }
	    if(listitem == 1)
	    {
	        ShowPlayerDialog(playerid,Extramedsdialog,0,"Extra meds",""cwhite"This perk, is for, when you take medical kits, it gives you an extra 5HP.","Set","Cancel");
	    }
	    if(listitem == 2)
	    {
	        ShowPlayerDialog(playerid,Extrafueldialog,0,"Extra fuel",""cwhite"This perk, is for, when you add fuel to your vehicle, it automatically add's a bit more.","Set","Cancel");
	    }
	    if(listitem == 3)
	    {
	        ShowPlayerDialog(playerid,Extraoildialog,0,"Extra oil",""cwhite"This perk, is for, when you add oil to your vehicle, it automatically add's a bit more.","Set","Cancel");
	    }
	    if(listitem == 4)
	    {
	        ShowPlayerDialog(playerid,Flashbangsdialog,0,"Flashbangs",""cwhite"When you enter a checkpoint, you receive +1 flashbangs.","Set","Cancel");
	    }
	    if(listitem == 5)
	    {
	        ShowPlayerDialog(playerid,Lessbitedialog,0,"Less bite damage",""cwhite"This perk, is for, when a zombie bites you, it does less damage to you.","Set","Cancel");
	    }
	    if(listitem == 6)
	    {
	        ShowPlayerDialog(playerid,Burstdialog,0,"Burst Run",""cwhite"This perk, gives you more speed when you press -"cred"SPRINT + CROUCH"cwhite"-","Set","Cancel");
	    }
	    if(listitem == 7)
	    {
	        ShowPlayerDialog(playerid,Medicdialog,0,"Medic",""cwhite"This perk allows you to assist other players with medical kits.","Set","Cancel");
	    }
	    if(listitem == 8)
	    {
	        ShowPlayerDialog(playerid,Morestaminadialog,0,"More Stamina",""cwhite"This perk allows you to run faster for 60 seconds.","Set","Cancel");
	    }
	    if(listitem == 9)
	    {
	        ShowPlayerDialog(playerid,Zombiebaitdialog,0,"Zombie bait",""cwhite"This perk allows you to throw a zombie bait, to attract zombies to a brain. -"cred"ALT + C"cwhite"-","Set","Cancel");
	    }
	    if(listitem == 10)
	    {
	        ShowPlayerDialog(playerid,Stealthdialog,0,"Stealth Mod",""cwhite"With this perk you'll hide from the zombies if you press -"cred"CROUCH"cwhite"-","Set","Cancel");
	    }
	    if(listitem == 11)
	    {
	        ShowPlayerDialog(playerid,Mechanicdialog,0,"Mechanic",""cwhite"This perk allows you to fix vehicles by pressing -"cred"CROUCH"cwhite"- while next to a car.","Set","Cancel");
	    }
	    if(listitem == 12)
	    {
	        ShowPlayerDialog(playerid,Extraammodialog,0,"More Ammo",""cwhite"This perk allows you to get more ammo, when you enter the checkpoint","Set","Cancel");
	    }
	    if(listitem == 13)
	    {
	        ShowPlayerDialog(playerid,Fielddoctordialog,0,"Field Doctor",""cwhite"This perk allows you to assist others with Health packs and Dizzy packs.","Set","Cancel");
	    }
	    if(listitem == 14)
	    {
	        ShowPlayerDialog(playerid,Rocketbootsdialog,0,"Rocket Boots",""cwhite"This perk allows you to jump higher, but you have a cool down between each jump of 8 seconds.","Set","Cancel");
	    }
	    if(listitem == 15)
	    {
	        ShowPlayerDialog(playerid,Homingbeacondialog,0,"Homing Beacon",""cwhite"This perk allows you to set a \"Signal Flare\" so you know your way to that point. -"cred"H"cwhite"-","Set","Cancel");
	    }
	    if(listitem == 16)
	    {
	        ShowPlayerDialog(playerid,Mastermechanicdialog,0,"Master Mechanic",""cwhite"This perk allows you to set fully fix a vehicle by pressing: -"cred"CROUCH"cwhite"-","Set","Cancel");
	    }
	    if(listitem == 17)
	    {
	        ShowPlayerDialog(playerid,Flameroundsdialog,0,"Flame rounds",""cwhite"This perk allows you to shoot a zombie and set him on fire. \n"cred"NOTE: To get flame rounds, go to the CP"cwhite".","Set","Cancel");
	    }
     	if(listitem == 18)
	    {
	        ShowPlayerDialog(playerid,Luckycharmdialog,0,"Lucky Charm",""cwhite"This perk is to make sure that, when you search for an item, you always get something. ","Set","Cancel");
	    }
	    if(listitem == 19)
	    {
	        ShowPlayerDialog(playerid,Grenadesdialog,0,"Grenades",""cwhite"This perk, is to, when you enter the checkpoint, you get grenades.","Set","Cancel");
	    }
	    if(listitem == 20)
	    {
	        ShowPlayerDialog(playerid,Firemodedialog,0,"Fire punch",""cwhite"This perk allows you to set a zombie on fire, when you punch them.","Set","Cancel");
	    }
	}
	if(dialogid == Logindialog)
	{
	    if(!response) Kick(playerid);
	    new buf[149];
    	WP_Hash(buf, sizeof (buf), inputtext);

	    if(strcmp(buf, PInfo[playerid][Password]) == 0)
	    {
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			SendClientMessage(playerid, -1, " ");
			//SendClientMessage(playerid, -1, "{CCCCCC}You've been logged in sucessfull.");
			LoadStats(playerid);
			//CheckRankup(playerid);
			PInfo[playerid][Logged] = 1;
			PInfo[playerid][Failedlogins] = 0;
			if(PInfo[playerid][Premium] == 1)
			    SendFMessage(playerid,white,"*"cgold"Thanks for supporting our community, gold member %s(%i)!",GetPName(playerid),playerid);
			if(PInfo[playerid][Premium] == 2)
			    SendFMessage(playerid,white,"*"cplat"Thanks for supporting our community, platinium member %s(%i)!",GetPName(playerid),playerid);

			SelectTextDraw(playerid, 0x81BEF7CC);
			PInfo[playerid][P_INTRO_OPTION] = INTRO_MAIN;
			for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_MAIN[i]);
		}
	    else
	    {
	        PInfo[playerid][Failedlogins]++;
	        if(PInfo[playerid][Failedlogins] == 3)
	        {
                format(buf,sizeof buf,"%s has been kicked for 3 failed attemps of logging in",GetPName(playerid));
                SendAdminMessage(red,buf);
                Kick(playerid);
	        }
			format(buf,sizeof buf,""cred"Attempts left: "cwhite"%d \n"cred"Attempts allowed: "cgreen"3 \n"cwhite"Please type in your password to "cligreen"load "cwhite"your status \n",3-PInfo[playerid][Failedlogins]);
            ShowPlayerDialog(playerid,Logindialog,3,"Login",buf,"Login","Cancel");
	    }
	}
	if(dialogid == Registerdialog)
	{
	    if(!response) return Kick(playerid);
	    if(strlen(inputtext) < 4 || strlen(inputtext) > 22)
	    {
			SendClientMessage(playerid,white,"» "cred"The password must be between 4 and 22 characters!");
			Kick(playerid);
			return 1;
		}
	    new buf[131];
    	WP_Hash(buf, sizeof (buf), inputtext);
    	RegisterPlayer(playerid,buf);

		SelectTextDraw(playerid, 0x81BEF7CC);
		PInfo[playerid][P_INTRO_OPTION] = INTRO_MAIN;
		for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_MAIN[i]);
	}
	return 0;
}

public OnPlayerText(playerid, text[])
{
    new temp[MAX_STRING];
	format(temp,sizeof temp,"%s",text);
    if(!anti_ip(temp))
	{
	    if(!PInfo[playerid][Muted])
	    {
	        if(PInfo[playerid][Level] > 0 && text[0] == '#')
		    {
		        new lvl[10];
		    	if(PInfo[playerid][Level] == 1) lvl = "Trial";
			    else if(PInfo[playerid][Level] == 2) lvl = "General";
			    else if(PInfo[playerid][Level] == 3) lvl = "Senior";
			    else if(PInfo[playerid][Level] == 4) lvl = "Lead";
			    else if(PInfo[playerid][Level] == 5) lvl = "Head";
				else if(PInfo[playerid][Level] == 6) lvl = "Developer";

		        new str[256];
		        format(str, sizeof str, "{FFFFFF}* %s {78006C}%s: %s", lvl, GetPName(playerid), text[1]);
		        SendAdminMessage(white, str);
		        return 0;
		    }

		    if(PInfo[playerid][Premium] > 0 && text[0] == '@')
		    {
		        new lvl[35];
		    	if(PInfo[playerid][Premium] == 1) lvl = ""cgold"Gold";
			    else if(PInfo[playerid][Premium] == 2) lvl = ""cplat"Platinum";

		        new str[256];
		        format(str, sizeof str, "{FFFFFF}[%s{FFFFFF}] {58D3F7}%s: %s", lvl, GetPName(playerid), text[1]);
		        SendPremiumMessage(white, str);
		        return 0;
		    }

		    if(PInfo[playerid][ClanID] > 0 && text[0] == '!')
		    {
		        new clan_name[MAX_PLAYER_NAME], DBResult:Result;

				format(DB_Query, sizeof(DB_Query), "SELECT NAME FROM CLANS WHERE ID = '%d'", PInfo[playerid][ClanID]);
				Result = db_query(Database, DB_Query);

		        new str[256];
				for (new a, rows = db_num_rows(Result); a < rows; a++)
				{
				    db_get_field(Result, 0, clan_name, sizeof clan_name);
				    format(str, sizeof str, "{A4A4A4}* {DF013A}[%s] {A4A4A4}%s: %s", clan_name, GetPName(playerid), text[1]);
				}
				db_free_result(Result);
		        SendClanMessage(white, str, PInfo[playerid][ClanID]);
			    return 0;
		    }

	     	new
				ircMsg[256];
			if(Team[playerid] == 1) format(ircMsg, sizeof(ircMsg), "03[%d] %s: %s", playerid, GetPName(playerid), text);
			else if(Team[playerid] == 1) format(ircMsg, sizeof(ircMsg), "02[%d] %s: %s", playerid, GetPName(playerid), text);
			IRC_GroupSay(gGroupID, IRC_CHANNEL, ircMsg);

		    if(gettime() < PInfo[playerid][P_ANTIFLOOD_TICKCOUNT] + 1) { SendClientMessage(playerid, red, "[Anti Flood] Calm down to send menssages."); return 0; }
	    	PInfo[playerid][P_ANTIFLOOD_TICKCOUNT] = gettime();

		    new msg[256];
		    if(Team[playerid] == 0) format(msg, sizeof(msg), ""cgrey"(ID: %i) %s: "cwhite"%s", playerid, GetPName(playerid), text);
		    else if(Team[playerid] == 1) format(msg, sizeof(msg), ""cgreen"(ID: %i) %s: "cwhite"%s", playerid, GetPName(playerid), text);
		    else if(Team[playerid] == 2) format(msg, sizeof(msg), ""cpurple"(ID: %i) %s: "cwhite"%s", playerid, GetPName(playerid), text);
		    SendClientMessageToAll(-1, msg);

		} else {
		    SendClientMessage(playerid, red, "|| You can't talk because you're muted! ||");
		    return 0;
		}
	}
    return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:INVALID_TEXT_DRAW)
	{
		switch(PInfo[playerid][P_INTRO_OPTION])
		{
			case INTRO_MAIN: return SelectTextDraw(playerid, 0x81BEF7CC);
			case INTRO_PLAY:
			{
				for(new i = 0; i != sizeof PTD_INTRO_PLAY[]; i ++) PlayerTextDrawHide(playerid, PTD_INTRO_PLAY[playerid][i]);
				for(new i = 0; i != sizeof TD_INTRO_PLAY; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_PLAY[i]);
				for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_MAIN[i]);
				SelectTextDraw(playerid, 0x81BEF7CC);
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				PInfo[playerid][P_INTRO_OPTION] = INTRO_MAIN;
				return 1;
			}
			case INTRO_RULES:
			{
				for(new i = 0; i != sizeof TD_INTRO_RULES; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_RULES[i]);
				for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_MAIN[i]);
				SelectTextDraw(playerid, 0x81BEF7CC);
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				PInfo[playerid][P_INTRO_OPTION] = INTRO_MAIN;
				return 1;
			}
			/*case INTRO_GUIDE:
			{
				for(new i = 0; i != sizeof TD_INTRO_GUIDE; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_GUIDE[i]);
				PlayerTextDrawHide(playerid, PTD_INTRO_GUIDE[playerid]);
				for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_MAIN[i]);
				SelectTextDraw(playerid, 0x81BEF7CC);
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				SendClientMessage(playerid, -1, " ");
				PInfo[playerid][P_INTRO_OPTION] = INTRO_MAIN;
				return 1;
			}*/
		}
		return 1;
	}

	if(clickedid == TD_INTRO_MAIN[2] && PInfo[playerid][P_INTRO_OPTION] == INTRO_MAIN) //play
    {
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");

		if(PInfo[playerid][Firstspawn] == 0)
		{
		    new infects;
			for(new i; i < MAX_PLAYERS;i++)
			{
			    if(!IsPlayerConnected(i)) continue;
				if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			    if(PInfo[i][Firstspawn] == 1) continue;
			    if(PlayerState[i] == false) continue;
			    if(Team[i] == ZOMBIE) infects++;
			}

			if(floatround(100.0 * floatdiv(infects, PlayersConnected)) >= 70 && CPscleared >= 3)
			{
				for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_MAIN[i]);
				for(new i = 0; i != sizeof TD_INTRO; i ++) TextDrawHideForPlayer(playerid, TD_INTRO[i]);
				for(new i = 0; i != sizeof PTD_INTRO_PLAY[]; i ++) PlayerTextDrawHide(playerid, PTD_INTRO_PLAY[playerid][i]);
				for(new i = 0; i != sizeof TD_INTRO_PLAY; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_PLAY[i]);

		        TogglePlayerControllable(playerid, false);
				GameTextForPlayer(playerid, "~w~Loading objects, wait..", 4000, 4);
				SetTimerEx("ObjectsLoaded", 4000, 0, "i", playerid);

				SetPlayerWeather(playerid, 9);
				SetPlayerTime(playerid, 6, 0);

				SendClientMessage(playerid, red, "|| You've been auto setted to zombie team because there's +70 infection percent and +3 CPs cleared. ||");

			    TimerBait[playerid] = SetTimerEx("BaitEffect", 700, true, "i", playerid);

			    if(PInfo[playerid][Premium] == 1 || PInfo[playerid][Premium] == 2)
			    {
					new DBResult:Result;
					format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
					Result = db_query(Database, DB_Query);
					if(db_num_rows(Result))
					{
						PInfo[playerid][ZSkin] = db_get_field_int(Result, 18);
					}
					if(PInfo[playerid][ZSkin] != 0)	{
				    	SetPlayerSkin(playerid, PInfo[playerid][ZSkin]); }
					else {
						SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]); }

					db_free_result(Result);
			    }

                TogglePlayerSpectating(playerid, false);
			    SetPlayerColor(playerid,purple);
			    SetPlayerArmour(playerid,0);
			    SetPlayerHealth(playerid,100.0);
			    SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]);
			    new rand = random(sizeof(RandomSpawnsZombie));
				SetPlayerPos(playerid, RandomSpawnsZombie[rand][0], RandomSpawnsZombie[rand][1], RandomSpawnsZombie[rand][2]);
				return 1;
			}

		    if(Team[playerid] == ZOMBIE)
			{
			    PInfo[playerid][P_INTRO_OPTION] = 0;
				PInfo[playerid][Firstspawn] = true;
				for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_MAIN[i]);
				for(new i = 0; i != sizeof TD_INTRO; i ++) TextDrawHideForPlayer(playerid, TD_INTRO[i]);
				for(new i = 0; i != sizeof PTD_INTRO_PLAY[]; i ++) PlayerTextDrawHide(playerid, PTD_INTRO_PLAY[playerid][i]);
				for(new i = 0; i != sizeof TD_INTRO_PLAY; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_PLAY[i]);
				CancelSelectTextDraw(playerid);
				StopAudioStreamForPlayer(playerid);

				TextDrawShowForPlayer(playerid,CPSCleared);
				TextDrawShowForPlayer(playerid,Infection);
				TextDrawShowForPlayer(playerid,CP_Name);
				TextDrawShowForPlayer(playerid,RadioBox);

				new rand = random(sizeof(RandomSpawnsZombie));
				SetSpawnInfo(playerid,0, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ], RandomSpawnsZombie[rand][0], RandomSpawnsZombie[rand][1], RandomSpawnsZombie[rand][2], 0.0, 0,0,0,0,0,0);
                TogglePlayerControllable(playerid, false);
                SendClientMessage(playerid, red,"|| We have detected that you left before the round ended ||");
  				SendClientMessage(playerid, red,"|| If you want to change teams you will have to wait to finish the current round ||");
				GameTextForPlayer(playerid, "~b~Loading objects, wait..", 4000, 4);
				SetTimerEx("ObjectsLoaded", 4000, false, "i", playerid);
				Team[playerid] = ZOMBIE;
				SetPlayerColor(playerid,purple);
				SetPlayerWeather(playerid, 16);
	    		SetPlayerTime(playerid, 20, 0);
                SpawnPlayer(playerid);

                if(PInfo[playerid][Premium] == 1 || PInfo[playerid][Premium] == 2)
			    {
					new DBResult:Result;
					format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
					Result = db_query(Database, DB_Query);
					if(db_num_rows(Result))
					{
						PInfo[playerid][ZSkin] = db_get_field_int(Result, 18);
					}
					db_free_result(Result);

					if(PInfo[playerid][ZSkin] != 0) {
						SetPlayerSkin(playerid, PInfo[playerid][ZSkin]);
					} else {
						SetSpawnInfo(playerid,0, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ], RandomSpawnsZombie[rand][0], RandomSpawnsZombie[rand][1], RandomSpawnsZombie[rand][2], 0.0, 0,0,0,0,0,0);
					}
				}

				TogglePlayerSpectating(playerid, false);
		  	}
		  	if(Team[playerid] == HUMAN)
			{
				PInfo[playerid][P_INTRO_OPTION] = 0;
				PInfo[playerid][Firstspawn] = true;
				for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_MAIN[i]);
				for(new i = 0; i != sizeof TD_INTRO; i ++) TextDrawHideForPlayer(playerid, TD_INTRO[i]);
				for(new i = 0; i != sizeof PTD_INTRO_PLAY[]; i ++) PlayerTextDrawHide(playerid, PTD_INTRO_PLAY[playerid][i]);
				for(new i = 0; i != sizeof TD_INTRO_PLAY; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_PLAY[i]);
				CancelSelectTextDraw(playerid);
				StopAudioStreamForPlayer(playerid);

				TextDrawShowForPlayer(playerid,CPSCleared);
				TextDrawShowForPlayer(playerid,Infection);
				TextDrawShowForPlayer(playerid,CP_Name);
				TextDrawShowForPlayer(playerid,RadioBox);

				new rand = random(sizeof Randomspawns);
				SetSpawnInfo(playerid,0, HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ], Randomspawns[rand][0],Randomspawns[rand][1],Randomspawns[rand][2], 0.0, 0,0,0,0,0,0);
				Team[playerid] = HUMAN;
				SendClientMessage(playerid,red,"|| We have detected that you left before the round ended ||");
		    	SendClientMessage(playerid,red,"|| If you want to change teams you will have to wait to finish the current round ||");
				PInfo[playerid][JustInfected] = 0;
				PInfo[playerid][Infected] = 0;
				PInfo[playerid][Dead] = 0;
				PInfo[playerid][CanBite] = 1;
				SetPlayerColor(playerid,green);
                SpawnPlayer(playerid);
				TogglePlayerSpectating(playerid, false);

                SetPlayerWeather(playerid, 32);
				SetPlayerTime(playerid, 0, 0);

				if(PInfo[playerid][Premium] == 0)
		  		{
					AddItem(playerid,"Small Medical Kits",5);
				    AddItem(playerid,"Medium Medical Kits",4);
			        AddItem(playerid,"Large Medical Kits",3);
			        AddItem(playerid,"Fuel",3);
			        AddItem(playerid,"Oil",3);
			        AddItem(playerid,"Flashlight",3);
			    }
			    if(PInfo[playerid][Premium] == 1)
			    {
			        SetPlayerArmour(playerid,100);
				    AddItem(playerid,"Small Medical Kits",17);
			     	AddItem(playerid,"Medium Medical Kits",17);
				    AddItem(playerid,"Large Medical Kits",17);
				    AddItem(playerid,"Fuel",17);
				    AddItem(playerid,"Oil",17);
				    AddItem(playerid,"Flashlight",17);
				    AddItem(playerid,"Dizzy Pills",17);
					/*new file[80];
					format(file,sizeof file,Userfile,GetPName(playerid));
					INI_Open(file);
					SetPlayerSkin(playerid,INI_ReadInt("SSkin"));
					INI_Close();*/
					new DBResult:Result;
					format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
					Result = db_query(Database, DB_Query);
					if(db_num_rows(Result))
					{
						PInfo[playerid][SSkin] = db_get_field_int(Result, 18);
					}
					db_free_result(Result);
					SetPlayerSkin(playerid, PInfo[playerid][SSkin]);
			    }
			    if(PInfo[playerid][Premium] == 2)
			    {
			        SetPlayerArmour(playerid,150);
				    AddItem(playerid,"Small Medical Kits",21);
			     	AddItem(playerid,"Medium Medical Kits",21);
				    AddItem(playerid,"Large Medical Kits",21);
				    AddItem(playerid,"Fuel",21);
				    AddItem(playerid,"Oil",21);
				    AddItem(playerid,"Flashlight",21);
				    AddItem(playerid,"Dizzy Pills",21);
				    AddItem(playerid,"Molotovs Guide",1);
				    AddItem(playerid,"Bouncing Bettys Guide",1);
				    /*new file[80];
					format(file,sizeof file,Userfile,GetPName(playerid));
					INI_Open(file);
					SetPlayerSkin(playerid,INI_ReadInt("SSkin"));
					INI_Close();*/
					new DBResult:Result;
					format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
					Result = db_query(Database, DB_Query);
					if(db_num_rows(Result))
					{
						PInfo[playerid][SSkin] = db_get_field_int(Result, 18);
					}
					db_free_result(Result);
					TogglePlayerSpectating(playerid, false);
					SetPlayerSkin(playerid, PInfo[playerid][SSkin]);
					rand = random(sizeof Platspawns);
					SetPlayerPos(playerid,Platspawns[rand][0],Platspawns[rand][1],Platspawns[rand][2]);
					SetPlayerFacingAngle(playerid,Platspawns[rand][3]);
			    }
			}
		    return 1;
		}

		SendClientMessage(playerid, 0xCCCCCCFF, "Press 'ESCAPE' to go back.");
		PInfo[playerid][P_INTRO_OPTION] = INTRO_PLAY;

		PlayerTextDrawSetPreviewModel(playerid, PTD_INTRO_PLAY[playerid][0], ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]);
		PlayerTextDrawSetPreviewModel(playerid, PTD_INTRO_PLAY[playerid][1], HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]);

		for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_MAIN[i]);
		for(new i = 0; i != sizeof PTD_INTRO_PLAY[]; i ++) PlayerTextDrawShow(playerid, PTD_INTRO_PLAY[playerid][i]);
		for(new i = 0; i != sizeof TD_INTRO_PLAY; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_PLAY[i]);
		return 1;
    }
	else if(clickedid == TD_INTRO_MAIN[3] && PInfo[playerid][P_INTRO_OPTION] == INTRO_MAIN) //rules
    {
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, 0xCCCCCCFF, "Press 'Left Click' to change page, press 'Right Click' to go back.");
		PInfo[playerid][P_INTRO_OPTION] = INTRO_GUIDE;
		for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_MAIN[i]);
		for(new i = 0; i != sizeof TD_INTRO_GUIDE; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_GUIDE[i]);
		CancelSelectTextDraw(playerid);
		UpdatePlayerGuide(playerid);
		PlayerTextDrawShow(playerid, PTD_INTRO_GUIDE[playerid]);
		return 1;
    }
    else if(clickedid == TD_INTRO_MAIN[4] && PInfo[playerid][P_INTRO_OPTION] == INTRO_MAIN) //rules
    {
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, -1, " ");
		SendClientMessage(playerid, 0xCCCCCCFF, "Press 'ESCAPE' to go back.");
		PInfo[playerid][P_INTRO_OPTION] = INTRO_RULES;
		for(new i = 0; i != sizeof TD_INTRO_MAIN; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_MAIN[i]);
		for(new i = 0; i != sizeof TD_INTRO_RULES; i ++) TextDrawShowForPlayer(playerid, TD_INTRO_RULES[i]);
		return 1;
    }

	else if(clickedid == TD_INTRO_PLAY[5] && PInfo[playerid][P_INTRO_OPTION] == INTRO_PLAY) //zombie
	{
		PInfo[playerid][P_INTRO_OPTION] = 0;
		PInfo[playerid][Firstspawn] = true;
		for(new i = 0; i != sizeof TD_INTRO; i ++) TextDrawHideForPlayer(playerid, TD_INTRO[i]);
		for(new i = 0; i != sizeof PTD_INTRO_PLAY[]; i ++) PlayerTextDrawHide(playerid, PTD_INTRO_PLAY[playerid][i]);
		for(new i = 0; i != sizeof TD_INTRO_PLAY; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_PLAY[i]);
		CancelSelectTextDraw(playerid);
		StopAudioStreamForPlayer(playerid);

		TextDrawShowForPlayer(playerid,CPSCleared);
		TextDrawShowForPlayer(playerid,Infection);
		TextDrawShowForPlayer(playerid,CP_Name);
		TextDrawShowForPlayer(playerid,RadioBox);

		new rand = random(sizeof(RandomSpawnsZombie));
		SetSpawnInfo(playerid,0, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ], RandomSpawnsZombie[rand][0], RandomSpawnsZombie[rand][1], RandomSpawnsZombie[rand][2], 0.0, 0,0,0,0,0,0);
        TogglePlayerControllable(playerid, false);
		GameTextForPlayer(playerid, "~w~Loading objects, wait..", 4000, 4);
		SetTimerEx("ObjectsLoaded", 4000, 0, "i", playerid);
		Team[playerid] = ZOMBIE;
		SetPlayerColor(playerid,purple);
  		SetPlayerWeather(playerid, 16);
	    SetPlayerTime(playerid, 20, 0);

		if(PInfo[playerid][Premium] == 1 || PInfo[playerid][Premium] == 2)
	    {
			/*new DBResult:Result;
			format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
			Result = db_query(Database, DB_Query);
			if(db_num_rows(Result))
			{
				PInfo[playerid][ZSkin] = db_get_field_int(Result, 18);
			}
			db_free_result(Result);*/
			if(PInfo[playerid][ZSkin] != 0) {
				SetPlayerSkin(playerid, PInfo[playerid][ZSkin]);
			} else {
                SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]);
			}
		}

        SetPlayerSkin(playerid, ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]);
		TogglePlayerSpectating(playerid, false);
		return 1;
	}

	else if(clickedid == TD_INTRO_PLAY[8] && PInfo[playerid][P_INTRO_OPTION] == INTRO_PLAY) //humano
	{
		PInfo[playerid][P_INTRO_OPTION] = 0;
		PInfo[playerid][Firstspawn] = true;
		for(new i = 0; i != sizeof TD_INTRO; i ++) TextDrawHideForPlayer(playerid, TD_INTRO[i]);
		for(new i = 0; i != sizeof PTD_INTRO_PLAY[]; i ++) PlayerTextDrawHide(playerid, PTD_INTRO_PLAY[playerid][i]);
		for(new i = 0; i != sizeof TD_INTRO_PLAY; i ++) TextDrawHideForPlayer(playerid, TD_INTRO_PLAY[i]);
		CancelSelectTextDraw(playerid);
		StopAudioStreamForPlayer(playerid);

		TextDrawShowForPlayer(playerid,CPSCleared);
		TextDrawShowForPlayer(playerid,Infection);
		TextDrawShowForPlayer(playerid,CP_Name);
		TextDrawShowForPlayer(playerid,RadioBox);

		new rand = random(sizeof Randomspawns);
		SetSpawnInfo(playerid,0, HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ], Randomspawns[rand][0],Randomspawns[rand][1],Randomspawns[rand][2], 0.0, 0,0,0,0,0,0);
		Team[playerid] = HUMAN;
		PInfo[playerid][JustInfected] = 0;
		PInfo[playerid][Infected] = 0;
		PInfo[playerid][Dead] = 0;
		PInfo[playerid][CanBite] = 1;
		SetPlayerColor(playerid,green);

		SetPlayerWeather(playerid, 32);
		SetPlayerTime(playerid, 0, 0);

		TogglePlayerSpectating(playerid, false);
		return 1;
	}

	else if(clickedid == TD_INTRO_PLAY[3] && PInfo[playerid][P_INTRO_OPTION] == INTRO_PLAY)  // <
	{
		if(PInfo[playerid][P_INTRO_SKIN_SELECTED][0] <= 0) PInfo[playerid][P_INTRO_SKIN_SELECTED][0] = sizeof(ZombieSkins) - 1;
		else PInfo[playerid][P_INTRO_SKIN_SELECTED][0] -- ;

		PlayerTextDrawSetPreviewModel(playerid, PTD_INTRO_PLAY[playerid][0], ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]);
		PlayerTextDrawShow(playerid, PTD_INTRO_PLAY[playerid][0]);
		return 1;
	}
	else if(clickedid == TD_INTRO_PLAY[4] && PInfo[playerid][P_INTRO_OPTION] == INTRO_PLAY)  // >
	{
		if(PInfo[playerid][P_INTRO_SKIN_SELECTED][0] >= sizeof(ZombieSkins) - 1) PInfo[playerid][P_INTRO_SKIN_SELECTED][0] = 0;
		else PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ++ ;

		PlayerTextDrawSetPreviewModel(playerid, PTD_INTRO_PLAY[playerid][0], ZombieSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][0] ]);
		PlayerTextDrawShow(playerid, PTD_INTRO_PLAY[playerid][0]);
		return 1;
	}

	else if(clickedid == TD_INTRO_PLAY[6] && PInfo[playerid][P_INTRO_OPTION] == INTRO_PLAY)  // <
	{
		if(PInfo[playerid][P_INTRO_SKIN_SELECTED][1] <= 0) PInfo[playerid][P_INTRO_SKIN_SELECTED][1] = sizeof(HumansSkins) - 1;
		else PInfo[playerid][P_INTRO_SKIN_SELECTED][1] -- ;

		PlayerTextDrawSetPreviewModel(playerid, PTD_INTRO_PLAY[playerid][1], HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]);
		PlayerTextDrawShow(playerid, PTD_INTRO_PLAY[playerid][1]);
		return 1;
	}
	else if(clickedid == TD_INTRO_PLAY[7] && PInfo[playerid][P_INTRO_OPTION] == INTRO_PLAY)  // >
	{
		if(PInfo[playerid][P_INTRO_SKIN_SELECTED][1] >= sizeof(HumansSkins) - 1) PInfo[playerid][P_INTRO_SKIN_SELECTED][1] = 0;
		else PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ++ ;

		PlayerTextDrawSetPreviewModel(playerid, PTD_INTRO_PLAY[playerid][1], HumansSkins[ PInfo[playerid][P_INTRO_SKIN_SELECTED][1] ]);
		PlayerTextDrawShow(playerid, PTD_INTRO_PLAY[playerid][1]);
		return 1;
	}
		// P_INTRO_SKIN_SELECTED
    return 1;
}

public OnPlayerUpdate(playerid)
{
	if(PInfo[playerid][Logged] != 1) return 1;

	if(Extra3CPs == 0)
	{
		new st[45], cp_name[128];
		if(CP_Activated == 0) cp_name = "~r~No Signal";
		else if(CP_Activated == 1) cp_name = "~w~~h~Saint Hospital";
		else if(CP_Activated == 2) cp_name = "~w~~h~Unity";
		else if(CP_Activated == 3) cp_name = "~w~~h~Glen Park";
		else if(CP_Activated == 4) cp_name = "~w~~h~Vinewood";
		else if(CP_Activated == 5) cp_name = "~w~~h~Movie Studio";
		else if(CP_Activated == 6) cp_name = "~w~~h~Inter Global";
		else if(CP_Activated == 7) cp_name = "~w~~h~Beach Coast";
		else if(CP_Activated == 8) cp_name = "~w~~h~Beach";
		else if(CP_Activated == 9) cp_name = "~w~~h~Grove Street";
		else if(CP_Activated == 10) cp_name = "~w~~h~Funfair";
		else if(CP_Activated == 11) cp_name = "~w~~h~Verdant Bluffs";
		else if(CP_Activated == 12) cp_name = "~w~~h~Mulholland";
		else if(CP_Activated == 13) cp_name = "~w~~h~Jefferson Church";
		else if(CP_Activated == 14) cp_name = "~w~~h~Police Department";
		else if(CP_Activated == 15) cp_name = "~w~~h~Super-Market";
		else if(CP_Activated == 16) cp_name = "~w~~h~Mansion";

		format(st,sizeof(st),"~w~CP: %s", cp_name);
		TextDrawSetString(CP_Name, st);
		TextDrawShowForAll(CP_Name);
	} else {
	    new st[45], cp_name[128];
		if(CP_Activated == 0) cp_name = "~r~No Signal";
		else if(CP_Activated == 1) cp_name = "~w~~h~Palomino Creek Center";
		else if(CP_Activated == 2) cp_name = "~w~~h~Red Country";
		else if(CP_Activated == 3) cp_name = "~w~~h~Red Country East";

		format(st,sizeof(st),"~w~CP: %s", cp_name);
		TextDrawSetString(CP_Name, st);
		TextDrawShowForAll(CP_Name);
	}

	if(CP_Activated == 0)
	{
 		TextDrawSetString(RadioBox, "~r~NO BATTERY LEFT");
        TextDrawShowForAll(RadioBox);
   	} else {
        new string[35];
	    format(string, sizeof string, "~w~RADIO_BATTERY: ~r~%d~w~/%d", CPVALUE-CPValue, CPVALUE);
 		TextDrawSetString(RadioBox, string);
        TextDrawShowForAll(RadioBox);
   	}

    new anim = GetPlayerAnimationIndex(playerid);
	if(anim == 1025 || anim == 1026 || anim == 1027 || anim == 1633 || anim == 227 || anim == 232 || anim == 1627 || anim == 54 ||anim == 1650 || anim == 1651 || anim == 132 ||anim == 133)
	{
		g_EnterAnim{playerid} = true;
	}
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
	{
		SendFMessageToAll(white, "[Anti-Cheats] "cred"''%s'' has been kicked from the server. (Reason: Jetpack Hack Detected!)", GetPName(playerid));
		KickEx(playerid);
	}
	if(GetPlayerMoney(playerid) > 0)
	{
	    SendFMessageToAll(white, "[Anti-Cheats] "cred"''%s'' has been kicked from the server. (Reason: Money Hack Detected!)", GetPName(playerid));
		KickEx(playerid);
	}
	if(aDuty{playerid} == true && PInfo[playerid][Level] > 0)
	{
	    new Float:hp;
	    GetPlayerHealth(playerid, hp);
	    if(hp < 100) SetPlayerHealth(playerid, 100);
	}
	new Float:obj_pos[6];
	GetObjectPos(airdropitem, obj_pos[0], obj_pos[1], obj_pos[2]);
	if(AirDroppedItem{airdropitem} == true && obj_pos[2] == caZAirdrop2)
	{
	    GetObjectPos(airdropitem, obj_pos[3], obj_pos[4], obj_pos[5]);
	    DestroyObject(airdropitem);
    	airdropitem = CreateObject(2919, obj_pos[3], obj_pos[4], obj_pos[5]-6.9, 0.0, 0.0, 90.0);
    	AirDroppedItem{airdropitem} = false;

    	foreach(new i:Player)
		{
			if(Team[i] == HUMAN) SetPlayerMapIcon(i, 50, obj_pos[3], obj_pos[4], obj_pos[5], 5, 0, MAPICON_LOCAL);
		}
	}

    new Keys, ud, lr;
    GetPlayerKeys(playerid, Keys, ud, lr);
    if(CheckCrouch[playerid] == 1)
	{
        switch(WeaponID[playerid])
		{
            case 23..25, 27, 29..34, 41:
			{
                if((Keys & KEY_CROUCH) && !((Keys & KEY_FIRE) || (Keys & KEY_HANDBRAKE)) && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK )
				{
                	if(Ammo[playerid][GetPlayerWeapon(playerid)] > GetPlayerAmmo(playerid))
					{
					    CBugTimes[playerid] += 1;
                    	if(CBugTimes[playerid] >= 2) OnPlayerCBug(playerid);
                    }
                }
        	}
        }
    }
    if(Team[playerid] == 2)
	{
		if(PInfo[playerid][ZPerk] == 20)
		{
		    SetPlayerAttachedObject(playerid, 5, 19063, 1, 0.000000, 0.060367, 0.000000, 83.558403, 84.249069, 347.783538 ); // Panza - Boomer
		}
		else
		{
		    RemovePlayerAttachedObject(playerid, 5);
		}
	}
    if(GetPlayerState(playerid)==PLAYER_STATE_ONFOOT)
	{
		new weaponid=GetPlayerWeapon(playerid),oldweapontype = GetWeaponType(OldWeapon[playerid]);
		new weapontype=GetWeaponType(weaponid);
		if(HoldingWeapon[playerid] == weaponid)
		    StopPlayerHoldingObject(playerid);

		if(Team[playerid] == ZOMBIE)
		    StopPlayerHoldingObject(playerid);

		if(OldWeapon[playerid] != weaponid)
		{
		    new modelid = GetWeaponModel(OldWeapon[playerid]);
		    if(modelid != 0 && oldweapontype != WEAPON_TYPE_NONE && oldweapontype != weapontype)
		    {
		        HoldingWeapon[playerid]=OldWeapon[playerid];
		        switch(oldweapontype)
		        {
		            case WEAPON_TYPE_LIGHT:
						SetPlayerHoldingObject(playerid, modelid, 8,0.0,-0.1,0.15, -100.0, 0.0, 0.0);

					case WEAPON_TYPE_MELEE:
					    SetPlayerHoldingObject(playerid, modelid, 7,0.0,0.0,-0.18, 100.0, 45.0, 0.0);

					case WEAPON_TYPE_HEAVY:
					    SetPlayerHoldingObject(playerid, modelid, 1, 0.2,-0.125,-0.1,0.0,25.0,180.0);
		        }
		    }
		}
		if(oldweapontype != weapontype)
			OldWeapon[playerid] = weaponid;
	}
	if(GetPlayerAnimationIndex(playerid))
    {
        new animlib[32];
        new animname[32];
        GetAnimationName(GetPlayerAnimationIndex(playerid),animlib,32,animname,32);
        if(strcmp(animlib, "SWIM", true) == 0 && !PInfo[playerid][Swimming])
        {
            PInfo[playerid][Swimming] = 1;
        }
        else if(strcmp(animlib, "SWIM", true) != 0 && PInfo[playerid][Swimming] && strfind(animname, "jump", true) == -1)
        {
            PInfo[playerid][Swimming] = 0;
        }
    }
    else if(PInfo[playerid][Swimming])
    {
        PInfo[playerid][Swimming] = 0;
    }
	return 1;
}

function BaitEffect(playerid)
{
    new Float:oPos[3];
    foreach(new i:Player)
	{
		GetObjectPos(PInfo[i][ZObject], oPos[0], oPos[1], oPos[2]);
		if(IsPlayerInRangeOfPoint(playerid, 5.0, oPos[0], oPos[1], oPos[2]))
		{
		    if(Team[playerid] == ZOMBIE)
			{
			    if(PInfo[i][ZObject] == INVALID_OBJECT_ID) continue;
			    if(IsPlayerInRangeOfPoint(playerid, 2.0, oPos[0], oPos[1], oPos[2])) continue;
			    SetActorToFacePlayer(playerid, PInfo[i][ZObject]);
			    ApplyAnimation(playerid, "PED", "WALK_old", 4.1, 1, 1, 1, 1, 1, 1);
			}
		}
	}
	return 1;
}

SetActorToFacePlayer(actorid, targetid) {
    new
        Float: pX,
        Float: pY,
        Float: tX,
        Float: tY
    ;
    return
        GetPlayerPos(targetid, tX, tY, Float: targetid) &&
        GetActorPos(actorid, pX, pY, Float: targetid) &&
        SetActorFacingAngle(actorid, -atan2(tX - pX, tY - pY))
    ;
}

stock GetPName(playerid)
{
	new p_name[24];
	GetPlayerName(playerid,p_name,24);
	return p_name;
}

stock SendClanMessage(color,text[], clanid)
{
	for(new i; i < MAX_PLAYERS;i++)
	{
		if(PInfo[i][ClanID] == clanid)
		{
			SendClientMessage(i,color,text);
		}
	}
	return 1;
}

stock SendPremiumMessage(color,text[])
{
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(PInfo[i][Premium] > 0)
	    {
			SendClientMessage(i,color,text);
	    }
	}
	return 1;
}

stock SendAdminMessage(color,text[])
{
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(PInfo[i][Level] > 0)
	    {
			SendClientMessage(i,color,text);
	    }
	}
	return 1;
}

stock LoadStats(playerid)
{
	new DBResult:Result;
	format(DB_Query, sizeof(DB_Query), "SELECT * FROM USERS WHERE NAME = '%s'", GetPName(playerid));
	Result = db_query(Database, DB_Query);
	if(db_num_rows(Result))
	{
		PInfo[playerid][Level] = db_get_field_int(Result, 4);
		PInfo[playerid][Rank] = db_get_field_int(Result, 5);
		PInfo[playerid][XP] = db_get_field_int(Result, 6);
		PInfo[playerid][Kills] = db_get_field_int(Result, 7);
		PInfo[playerid][Deaths] = db_get_field_int(Result, 8);
		PInfo[playerid][Teamkills] = db_get_field_int(Result, 9);
		PInfo[playerid][Infects] = db_get_field_int(Result, 10);
		PInfo[playerid][SPerk] = db_get_field_int(Result, 11);
		PInfo[playerid][ZPerk] = db_get_field_int(Result, 12);
		PInfo[playerid][Bites] = db_get_field_int(Result, 13);
		PInfo[playerid][CPCleared] = db_get_field_int(Result, 14);
		PInfo[playerid][Vomited] = db_get_field_int(Result, 15);
		PInfo[playerid][Assists] = db_get_field_int(Result, 16);
		PInfo[playerid][Premium] = db_get_field_int(Result, 17);
		PInfo[playerid][SSkin] = db_get_field_int(Result, 18);
		PInfo[playerid][ZSkin] = db_get_field_int(Result, 19);
		PInfo[playerid][Warns] = db_get_field_int(Result, 20);
		PInfo[playerid][Banned] = db_get_field_int(Result, 21);
		db_get_field(Result, 22, PInfo[playerid][Warn1], 64);
		db_get_field(Result, 23, PInfo[playerid][Warn2], 64);
		db_get_field(Result, 24, PInfo[playerid][Warn3], 64);
		PInfo[playerid][Screams] = db_get_field_int(Result, 25);
		PInfo[playerid][Muted] = db_get_field_int(Result, 26);
		PInfo[playerid][ClanID] = db_get_field_int(Result, 27);
		PInfo[playerid][ClanLeaderID] = db_get_field_int(Result, 28);
	}
	db_free_result(Result);
	PlaySound(playerid,6401);
	SetPlayerScore(playerid,PInfo[playerid][Rank]);
	return 1;
}

stock RegisterPlayer(playerid,pass[])
{
	format(DB_Query, sizeof DB_Query, "INSERT INTO USERS (NAME, PASS, IP, RANK, WARN1, WARN2, WARN3) VALUES ('%s', '%s', '%s', '1', 'None', 'None', 'None')", GetPName(playerid), pass, GetIP(playerid));
	db_query(Database, DB_Query);
 	PInfo[playerid][Logged] = 1;
	return 1;
}

stock SaveStats(playerid)
{
	if(PInfo[playerid][Logged] != 1) return 1;
	new str[64];
    format(DB_Query, sizeof(DB_Query), "");
	strcat(DB_Query, "UPDATE USERS SET ");
	format(str, 64, "IP = '%s',", GetIP(playerid)); strcat(DB_Query, str);
	format(str, 64, "LEVEL = '%d',", PInfo[playerid][Level]); strcat(DB_Query, str);
	format(str, 64, "RANK = '%d',", PInfo[playerid][Rank]); strcat(DB_Query, str);
	format(str, 64, "XP = '%d',", PInfo[playerid][XP]); strcat(DB_Query, str);
	format(str, 64, "KILLS = '%d',", PInfo[playerid][Kills]); strcat(DB_Query, str);
	format(str, 64, "DEATHS = '%d',", PInfo[playerid][Deaths]); strcat(DB_Query, str);
	format(str, 64, "TEAMKILLS = '%d',", PInfo[playerid][Teamkills]); strcat(DB_Query, str);
	format(str, 64, "INFECTS = '%d',", PInfo[playerid][Infects]); strcat(DB_Query, str);
	format(str, 64, "SPERK = '%d',", PInfo[playerid][SPerk]); strcat(DB_Query, str);
	format(str, 64, "ZPERK = '%d',", PInfo[playerid][ZPerk]); strcat(DB_Query, str);
	format(str, 64, "BITES = '%d',", PInfo[playerid][Bites]); strcat(DB_Query, str);
	format(str, 64, "CPCLEARED = '%d',", PInfo[playerid][CPCleared]); strcat(DB_Query, str);
	format(str, 64, "VOMITED = '%d',", PInfo[playerid][Vomited]); strcat(DB_Query, str);
	format(str, 64, "ASSISTS = '%d',", PInfo[playerid][Assists]); strcat(DB_Query, str);
	format(str, 64, "PREMIUM = '%d',", PInfo[playerid][Premium]); strcat(DB_Query, str);
	format(str, 64, "SSKIN = '%d',", PInfo[playerid][SSkin]); strcat(DB_Query, str);
	format(str, 64, "ZSKIN = '%d',", PInfo[playerid][ZSkin]); strcat(DB_Query, str);
	/*format(str, 64, "Warns = '%d',", PInfo[playerid][Warns]); strcat(DB_Query, str);
	format(str, 64, "Banned = '%d',", PInfo[playerid][Banned]); strcat(DB_Query, str);
	format(str, 64, "Warn1 = '%s',", PInfo[playerid][Warn1]); strcat(DB_Query, str);
	format(str, 64, "Warn2 = '%s',", PInfo[playerid][Warn2]); strcat(DB_Query, str);
	format(str, 64, "Warn3 = '%s'", PInfo[playerid][Warn3]); strcat(DB_Query, str);*/
	format(str, 64, "SCREAMS = '%d',", PInfo[playerid][Screams]); strcat(DB_Query, str);
	format(str, 64, "MUTED = '%d',", PInfo[playerid][Muted]); strcat(DB_Query, str);
	format(str, 64, "CLANID = '%d',", PInfo[playerid][ClanID]); strcat(DB_Query, str);
	format(str, 64, "CLANLEADERID = '%d'", PInfo[playerid][ClanLeaderID]); strcat(DB_Query, str);
    format(str, 64, " WHERE NAME = '%s'", GetPName(playerid)); strcat(DB_Query, str);
	db_query(Database, DB_Query);
	return 1;
}

stock SaveClanStats(clanid)
{
    new str[64];
    format(DB_Query, sizeof(DB_Query), "");
	strcat(DB_Query, "UPDATE CLANS SET ");
	format(str, 64, "XP = '%d',", CInfo[clanid][C_XP]); strcat(DB_Query, str);
	format(str, 64, "KILLS = '%d',", CInfo[clanid][C_KILLS]); strcat(DB_Query, str);
	format(str, 64, "INFECTS = '%d'", CInfo[clanid][C_INFECTS]); strcat(DB_Query, str);
	format(str, 64, " WHERE ID = '%d'", clanid); strcat(DB_Query, str);
	db_query(Database, DB_Query);
	return 1;
}

function ShowXP(playerid)//Biggest
{
    TextDrawHideForPlayer(playerid,GainXPTD[playerid]);
 	TextDrawBackgroundColor(GainXPTD[playerid], 255);
	TextDrawFont(GainXPTD[playerid], 1);
	TextDrawLetterSize(GainXPTD[playerid], 0.780000, 4.100000);
	TextDrawColor(GainXPTD[playerid], -1);
	TextDrawSetOutline(GainXPTD[playerid], 1);
	TextDrawSetProportional(GainXPTD[playerid], 1);
	SetTimerEx("HideXP",1000,0,"i",playerid);
	new string[7];
	format(string,sizeof string,"+%i XP",PInfo[playerid][CurrentXP]);
	TextDrawSetString(GainXPTD[playerid],string);
	TextDrawShowForPlayer(playerid,GainXPTD[playerid]);
	PlaySound(playerid,1057);
	return 1;
}

function ShowXP1(playerid)//Medium
{
    TextDrawHideForPlayer(playerid,GainXPTD[playerid]);
 	TextDrawBackgroundColor(GainXPTD[playerid], 255);
	TextDrawFont(GainXPTD[playerid], 1);
	TextDrawLetterSize(GainXPTD[playerid], 0.659999, 3.200001);
	TextDrawColor(GainXPTD[playerid], -1);
	TextDrawSetOutline(GainXPTD[playerid], 1);
	TextDrawSetProportional(GainXPTD[playerid], 1);
	SetTimerEx("ShowXP",300,0,"i",playerid);
	TextDrawShowForPlayer(playerid,GainXPTD[playerid]);
	PlaySound(playerid,1083);
	return 1;
}

function HideXP(playerid)
{
	TextDrawHideForPlayer(playerid,GainXPTD[playerid]);
	TextDrawBackgroundColor(GainXPTD[playerid], 255);
	TextDrawFont(GainXPTD[playerid], 1);
	TextDrawLetterSize(GainXPTD[playerid], 0.610000, 2.600002);
	TextDrawColor(GainXPTD[playerid], -1);
	TextDrawSetOutline(GainXPTD[playerid], 1);
	TextDrawSetProportional(GainXPTD[playerid], 1);
	PInfo[playerid][ShowingXP] = 0;
	return 1;
}

stock PlaySound(playerid,soundid)
{
	new Float:p[3];
	GetPlayerPos(playerid, p[0], p[1], p[2]);
	PlayerPlaySound(playerid, soundid, p[0], p[1], p[2]);
	return 1;
}

stock PlayNearSound(playerid,soundid)
{
	new Float:p[3];
	GetPlayerPos(playerid, p[0], p[1], p[2]);
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(IsPlayerInRangeOfPoint(i,7.0,p[0], p[1], p[2]))
	        PlayerPlaySound(i, soundid, p[0], p[1], p[2]);
	}
	return 1;
}

/*stock PlaySoundForAll(soundid)
{
	new Float:p[3];
	foreach(Player,i)
	{
		GetPlayerPos(i, p[0], p[1], p[2]);
		PlayerPlaySound(i, soundid, p[0], p[1], p[2]);
	}
	return 1;
}*/

function CantBite(playerid)
{
    PInfo[playerid][CanBite] = 1;
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    if(PInfo[playerid][Logged] != 1) return SendClientMessage(playerid, red, "|| You have to be logged in. ||");
	new premtxt[10];
	if(PInfo[clickedplayerid][Premium] == 0) { premtxt = "None"; }
	else if(PInfo[clickedplayerid][Premium] == 1) { premtxt = "Gold"; }
	else if(PInfo[clickedplayerid][Premium] == 2) { premtxt = "Platinum"; }

    if(PInfo[playerid][Level] > 0)
    {
        new string[350], pip[16], Float:health, Float:Armour;

        GetPlayerHealth(clickedplayerid, health);
        GetPlayerArmour(clickedplayerid, Armour);
		GetPlayerIp(clickedplayerid, pip, sizeof(pip));
        format(string, sizeof string, ""cgold"Player: %s | IP: %s\n\n"cwhite"Rank: %i - XP: %i/%i - Kills: %i - Team Kills: %i - Deaths: %i - SPerk: %i - ZPerk: %i\n"cwhite"CPs Cleared: %i - Infects: %i - Bites: %i - Assists: %i - Vomited: %i - Premium: %s\n"cwhite"Health: %f - Armour: %f - Warnings: %d/3",
            GetPName(clickedplayerid),
            pip,
			PInfo[clickedplayerid][Rank],
			PInfo[clickedplayerid][XP],
			PInfo[clickedplayerid][XPToRankUp],
			PInfo[clickedplayerid][Kills],
			PInfo[clickedplayerid][Teamkills],
			PInfo[clickedplayerid][Deaths],
			PInfo[clickedplayerid][SPerk]+1,
			PInfo[clickedplayerid][ZPerk]+1,
			PInfo[clickedplayerid][CPCleared],
			PInfo[clickedplayerid][Infects],
			PInfo[clickedplayerid][Bites],
			PInfo[clickedplayerid][Assists],
			PInfo[clickedplayerid][Vomited],
			premtxt,
			health,
			Armour,
			PInfo[clickedplayerid][Warns]
		);
		ShowPlayerDialog(playerid, Clickstatsdialog, DIALOG_STYLE_MSGBOX, "STATS BOX", string, ">>", "<<");
	} else {
	    new string[350], Float:health, Float:Armour;
     	GetPlayerHealth(clickedplayerid, health);
        GetPlayerArmour(clickedplayerid, Armour);
        format(string, sizeof string, ""cgold"Player: %s\n\n"cwhite"Rank: %i - XP: %i/%i - Kills: %i - Team Kills: %i - Deaths: %i - SPerk: %i - ZPerk: %i\n"cwhite"CPs Cleared: %i - Infects: %i - Bites: %i - Assists: %i - Vomited: %i - Premium: %s\n"cwhite"Health: %f - Armour %f - Warnings: %d/3",
            GetPName(clickedplayerid),
			PInfo[clickedplayerid][Rank],
			PInfo[clickedplayerid][XP],
			PInfo[clickedplayerid][XPToRankUp],
			PInfo[clickedplayerid][Kills],
			PInfo[clickedplayerid][Teamkills],
			PInfo[clickedplayerid][Deaths],
			PInfo[clickedplayerid][SPerk]+1,
			PInfo[clickedplayerid][ZPerk]+1,
			PInfo[clickedplayerid][CPCleared],
			PInfo[clickedplayerid][Infects],
			PInfo[clickedplayerid][Bites],
			PInfo[clickedplayerid][Assists],
			PInfo[clickedplayerid][Vomited],
			premtxt,
			health,
			Armour,
			PInfo[clickedplayerid][Warns]
		);
		ShowPlayerDialog(playerid, Clickstatsdialog, DIALOG_STYLE_MSGBOX, "STATS BOX", string, ">>", "<<");
	}
    return 1;
}

function UpdateStats()
{
    new string[256], string2[64];
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		if(PInfo[i][Dead] == 1) continue;
	    SetPlayerScore(i,PInfo[i][Rank]);
        //if(PInfo[i][Dead] == 1) continue;
		if(Team[i] == HUMAN)
	    {

		    format(string,sizeof string,"Rank:_%i~n~Kills:_%i~n~TeamKills:_%i~n~Deaths:_%i~n~Perk:_%i~n~CPs_Cleared:_%i~n~Achievements:_Soon",
				PInfo[i][Rank],
				PInfo[i][Kills],
				PInfo[i][Teamkills],
				PInfo[i][Deaths],
				PInfo[i][SPerk]+1,
				PInfo[i][CPCleared]
			);

		    PlayerTextDrawSetString(i, StatsBoxDraw[i], string);

			if(PInfo[i][Premium] == 1)
				format(string2,sizeof string2,""cgold"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]);
			else if(PInfo[i][Premium] == 2)
			    format(string2,sizeof string2,""cplat"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]);
			else
			    format(string2,sizeof string2,""cgreen"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]);
			Update3DTextLabelText(PInfo[i][Ranklabel],green,string2);

			new Float:health;
		    GetPlayerHealth(i,health);
			MakeHealthEven(i,health);
			GetPlayerHealth(i,health);
			if(PInfo[i][Swimming] == 1)
			{
				SetPlayerHealth(i,health-0.5);
				GetPlayerHealth(i,health);
				if(health <= 5)
				{
				    GetPlayerPos(i, ZPS[i][0], ZPS[i][1], ZPS[i][2]);
				 	GetPlayerFacingAngle(i, ZPS[i][3]);

				    SetSpawnInfo(i,0,ZombieSkins[random(sizeof(ZombieSkins))], ZPS[i][0], ZPS[i][1], ZPS[i][2], ZPS[i][3],0,0,0,0,0,0);
			        SetPlayerSkin(i,ZombieSkins[random(sizeof(ZombieSkins))]);
			        InfectPlayer(i);
				}
			}

			if(Mission[i] == 1)
			{
				if(MissionPlace[i][1] == 1) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[i][0] == 1)
				    {
				        if(IsPlayerInRangeOfPoint(i,2.0,Locations[0][0],Locations[0][1],Locations[0][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for bottles.",3000,3);
				        }
				    }
				    if(MissionPlace[i][0] == 2)
				    {
				        if(IsPlayerInRangeOfPoint(i,2.0,Locations[1][0],Locations[1][1],Locations[1][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for bottles.",3000,3);
				        }
				    }
				}
				if(MissionPlace[i][1] == 2) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[i][0] == 3)
				    {
                        if(IsPlayerInRangeOfPoint(i,2.0,Locations[2][0],Locations[2][1],Locations[2][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some cloth.",3000,3);
				        }
					}
					else if(MissionPlace[i][0] == 4)
				    {
                        if(IsPlayerInRangeOfPoint(i,2.0,Locations[3][0],Locations[3][1],Locations[3][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some cloth.",3000,3);
				        }
					}
				}
				if(MissionPlace[i][1] == 3) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[i][0] == 5)
				    {
                        if(IsPlayerInRangeOfPoint(i,2.0,Locations[4][0],Locations[4][1],Locations[4][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some glue.",3000,3);
				        }
					}
					else if(MissionPlace[i][0] == 6)
				    {
                        if(IsPlayerInRangeOfPoint(i,2.0,Locations[5][0],Locations[5][1],Locations[5][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some glue.",3000,3);
				        }
					}
				}
			}
			if(Mission[i] == 2)
			{
				if(MissionPlace[i][1] == 1) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[i][0] == 1)
				    {
				        if(IsPlayerInRangeOfPoint(i,2.0,Locations[0][0],Locations[0][1],Locations[0][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some ethanol.",3000,3);
				        }
				    }
				    if(MissionPlace[i][0] == 2)
				    {
				        if(IsPlayerInRangeOfPoint(i,2.0,Locations[1][0],Locations[1][1],Locations[1][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some ethanol.",3000,3);
				        }
				    }
				}
				if(MissionPlace[i][1] == 2) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[i][0] == 3)
				    {
                        if(IsPlayerInRangeOfPoint(i,2.0,Locations[2][0],Locations[2][1],Locations[2][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some fuse.",3000,3);
				        }
					}
					else if(MissionPlace[i][0] == 4)
				    {
                        if(IsPlayerInRangeOfPoint(i,2.0,Locations[3][0],Locations[3][1],Locations[3][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some fuse.",3000,3);
				        }
					}
				}
				if(MissionPlace[i][1] == 3) //From 1 to 3, to know if its clothes, liquid or cans.
				{
				    if(MissionPlace[i][0] == 5)
				    {
                        if(IsPlayerInRangeOfPoint(i,2.0,Locations[4][0],Locations[4][1],Locations[4][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some cans.",3000,3);
				        }
					}
					else if(MissionPlace[i][0] == 6)
				    {
                        if(IsPlayerInRangeOfPoint(i,2.0,Locations[5][0],Locations[5][1],Locations[5][2]))
				        {
				            GameTextForPlayer(i,"~w~Press ~r~~h~Crouch ~w~to search for some cans.",3000,3);
				        }
					}
				}
			}
    	}
    	else if(Team[i] == ZOMBIE)
    	{
    	    if(PInfo[i][Premium] == 1)
				format(string2,sizeof string2,""cgold"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]);
			else if(PInfo[i][Premium] == 2)
			    format(string2,sizeof string2,""cplat"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]);
			else
			    format(string2,sizeof string2,""cpurple"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]);
			Update3DTextLabelText(PInfo[i][Ranklabel],0x00E800FF,string2);

		    format(string,sizeof string,"Rank:_%i~n~Infects:_%i~n~Deaths:_%i~n~Bites:_%i~n~Perk:_%i~n~Assists:_%i~n~Vomited:_%i",
				PInfo[i][Rank],
				PInfo[i][Infects],
				PInfo[i][Deaths],
				PInfo[i][Bites],
				PInfo[i][ZPerk]+1,
				PInfo[i][Assists],
				PInfo[i][Vomited]
			);

		    PlayerTextDrawSetString(i, StatsBoxDraw[i], string);

			new Float:Health;
		    GetPlayerHealth(i,Health);
		    if(Health >= 5 && Health <= 10)
				SetPlayerHealth(i,5);
    	}

		if(PInfo[i][ZX] != 0)
		{
		    for(new f; f < MAX_PLAYERS;f++)
		    {
		        if(!IsPlayerConnected(f)) continue;
	    		if(PInfo[f][Dead] == 1) continue;
	    		if(Team[f] == HUMAN) continue;
       			if(PInfo[f][ZPerk] == 17) continue;
	    		if(IsPlayerInRangeOfPoint(f,16.0,PInfo[i][ZX],PInfo[i][ZY],PInfo[i][ZZ]))
	   			{
	   			    TurnPlayerFaceToPos(f,PInfo[i][ZX],PInfo[i][ZY]);
	    			ApplyAnimation(f, "PED" , "WALK_SHUFFLE" , 2.0 , 0 , 1 , 1 , 0 , 5000 , 1);
    			}
		    }
		}
		for(new j; j < sizeof(Searchplaces);j++)
		{
		    if(IsPlayerInRangeOfPoint(i,2.0,Searchplaces[j][0],Searchplaces[j][1],Searchplaces[j][2]))
			{
			    GameTextForPlayer(i,"~n~~n~~r~~h~Press ~w~~k~~PED_DUCK~~r~~h~ to search for items",3500,3);
			}
		}
		for(new j; j < sizeof(OilFuelSearch);j++)
		{
		    if(IsPlayerInRangeOfPoint(i,2.0,OilFuelSearch[j][0],OilFuelSearch[j][1],OilFuelSearch[j][2]))
			{
			    GameTextForPlayer(i,"~n~~n~~r~~h~Press ~w~~k~~PED_DUCK~~r~~h~ to search for fuel/oil",3500,3);
			}
		}
		if(IsPlayerInAnyVehicle(i) && Team[i] == HUMAN)
		{
		    new Float:health;
		    GetVehicleHealth(GetPlayerVehicleID(i),health);
		    if(health <= 200) SetVehicleHealth(GetPlayerVehicleID(i),350);
		}
		if(PInfo[i][PlantedBettys] > 0)
		{
		    for(new j; j < MAX_PLAYERS;j++)
		    {
		        if(!IsPlayerConnected(j)) continue;
		        if(PInfo[j][Dead] == 1) continue;
		        if(IsPlayerInRangeOfObject(j,10.0,PInfo[i][BettyObj1]))
	        	{
	        	    if(PInfo[i][BettyActive1] == 1)
	        	    {
				    	new Float:x,Float:y,Float:z;
				        GetObjectPos(PInfo[i][BettyObj1],x,y,z);
			            MoveObject(PInfo[i][BettyObj1],x,y,z+1.3,5);
			            SetTimerEx("ExplodeBetty",300,false,"ii",i,1);
	           		}
		        }
		        if(IsPlayerInRangeOfObject(j,10.0,PInfo[i][BettyObj2]))
		        {
		            if(PInfo[i][BettyActive2] == 1)
	        	    {
			            new Float:x,Float:y,Float:z;
			            GetObjectPos(PInfo[i][BettyObj2],x,y,z);
			            MoveObject(PInfo[i][BettyObj2],x,y,z+1.3,5);
			            SetTimerEx("ExplodeBetty",300,false,"ii",i,2);
		            }
		        }
		        if(IsPlayerInRangeOfObject(j,10.0,PInfo[i][BettyObj3]))
		        {
		            if(PInfo[i][BettyActive3] == 1)
	        	    {
			            new Float:x,Float:y,Float:z;
			            GetObjectPos(PInfo[i][BettyObj3],x,y,z);
			            MoveObject(PInfo[i][BettyObj3],x,y,z+1.3,5);
			            SetTimerEx("ExplodeBetty",300,false,"ii",i,3);
		            }
		        }
      		}
		}
		if(Team[i] == ZOMBIE)
		{
		    new Float:health;
			if((GetTickCount() - PInfo[i][Allowedtovomit]) >= VOMITTIME && PInfo[i][Vomitmsg] == 0)
			    SendClientMessage(i,red,"You have your stomach full (vomit ready)"),PInfo[i][Vomitmsg] = 1;
			if((GetTickCount() - PInfo[i][CanJump] >= 3500)) PInfo[i][Jumps] = 0;
            for(new j; j < MAX_PLAYERS;j++)
		    {
		        if(Team[j] == ZOMBIE) continue;
		        if(!IsPlayerConnected(j)) continue;
		        if(PInfo[j][Dead] == 1) continue;
				if(IsPlayerInRangeOfPoint(j,4.0,PInfo[i][Vomitx],PInfo[i][Vomity],PInfo[i][Vomitz]))
				{
				    if(IsPlayerInAnyVehicle(j))
				    {
				        SetVehicleHealth(GetPlayerVehicleID(j),350.0);
				        StartVehicle(GetPlayerVehicleID(j),0);
						VehicleStarted[GetPlayerVehicleID(j)] = 0;
				    }
				    else
				    {
            			GetPlayerHealth(j,health);
						MakeHealthEven(j,health);
				        DamagePlayer(i,j);
      					/*if(health <= 6.0)
      					{
                            GivePlayerXP(i);
                            PInfo[i][Infects]++;
						    SetPlayerHealth(j,100);
						    new Float:x,Float:y,Float:z;
					 		GetPlayerPos(j,x,y,z);
							SetPlayerPos(j,x,y,z+4);
							SpawnPlayer(j);
							PInfo[j][Deaths]++;
							PInfo[j][Dead] = 1;
					        PInfo[j][JustInfected] = 1;
					        Team[j] = ZOMBIE;
					        GameTextForPlayer(j,"~r~~h~Infected!",4000,3);
					        SetPlayerColor(j,purple);
					        CheckRankup(i);
           				}*/
				    }
				}
			}
		}
    	SetPlayerTime(i,0,0);
	}
	return 1;
}

function Dizzy()
{
	for(new i; i < MAX_PLAYERS;i++)
	{
		if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		if(Team[i] == ZOMBIE) continue;
		if(Team[i] == HUMAN && PInfo[i][Infected] == 0) continue;
		if(PInfo[i][TokeDizzy] == 0) SetPlayerDrunkLevel(i,6000);
		else SetPlayerDrunkLevel(i,1000);
		SetPlayerWeather(i,1591);
		if(PInfo[i][Lighton] == 1)
		{
            RemovePlayerAttachedObject(i,3);
            RemovePlayerAttachedObject(i,4);
            PInfo[i][Lighton] = 0;
            RemoveItem(i,"Flashlight",1);
            new string[90];
 			format(string,sizeof string,""cjam"%s flashlight has runned out of bateries.",GetPName(i));
			SendNearMessage(i,white,string,30);
		}
	}

	for(new i; i < MAX_VEHICLES;i++)
	{
		if(!IsVehicleOccupied(i)) continue;
		if(!IsVehicleStarted(i)) continue;
		Fuel[i]-=10;
		Oil[i]-=10;
		UpdateVehicleFuelAndOil(i);
	}

	SetTimer("Enddizzy",5000,false);
	return 1;
}

function Enddizzy()
{
    for(new i; i < MAX_PLAYERS;i++)
	{
		if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		if(Team[i] == ZOMBIE) continue;
		if(Team[i] == HUMAN && PInfo[i][Infected] == 0) continue;
		SetPlayerDrunkLevel(i,0);
		SetPlayerWeather(i,Weather);
	}
	return 1;
}

function WeatherUpdate()
{
    new Weathers[] =
	{
	    214,
	    2451,
	    1381,
	    1450,
	    1462,
     	1601
	};
	new id;
	id = Weathers[random(sizeof Weathers)];
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
	    if(Team[i] == ZOMBIE) SetPlayerWeather(i,2718);
	    SetPlayerWeather(i,id);
		Weather = id;
		#if snowing == true
		{
			if(Snow == 1)
		    {
				if(GetPlayerInterior(i) == 0)
				{
		  			new Float:Pos[3];
					GetPlayerPos(i,Pos[0],Pos[1],Pos[2]);
					Pos[2] = Pos[2]-4;
			     	for(new g = 0; g < 2; g++)
					{
						if(SnowCreated[i] == 0)SnowObj[i][g] = CreateDynamicObject(18864,Pos[0]+random(5),Pos[1],Pos[2],0,0,random(45), -1, -1, i,150.0),SnowCreated[i] = 1;
			     		SetDynamicObjectPos(SnowObj[i][g],Pos[0]+random(5),Pos[1],Pos[2]);
			        	SetDynamicObjectRot(SnowObj[i][g],0,0,random(45));
			        	SnowCreated[i] = 1;
			      	}
		    	}
			}
			else
			{
			    if(Snow == 0)
				{
				    if(SnowCreated[i] == 1)
			        {
				  		for(new g = 0; g < 2; g++)
						{
				   			DestroyDynamicObject(SnowObj[i][g]);
						}
						SnowCreated[i] = 0;
					}
					else continue;
				}
			}
		}
		#endif
	}
	return 1;
}

stock CheckRankup(playerid,gw=0)
{
	new str[64];
    switch(PInfo[playerid][Rank])
	{
	    case 1:PInfo[playerid][XPToRankUp] = 50;
	    case 2: PInfo[playerid][XPToRankUp] = 100;
	    case 3: PInfo[playerid][XPToRankUp] = 200;
	    case 4: PInfo[playerid][XPToRankUp] = 400;
	    case 5: PInfo[playerid][XPToRankUp] = 600;
	    case 6: PInfo[playerid][XPToRankUp] = 800;
	    case 7: PInfo[playerid][XPToRankUp] = 1000;
	    case 8: PInfo[playerid][XPToRankUp] = 1250;
	    case 9: PInfo[playerid][XPToRankUp] = 1500;
	    case 10: PInfo[playerid][XPToRankUp] = 2000;
	    case 11: PInfo[playerid][XPToRankUp] = 2500;
	    case 12: PInfo[playerid][XPToRankUp] = 3000;
	    case 13: PInfo[playerid][XPToRankUp] = 3500;
	    case 14: PInfo[playerid][XPToRankUp] = 4000;
	    case 15: PInfo[playerid][XPToRankUp] = 5000;
	    case 16: PInfo[playerid][XPToRankUp] = 6000;
	    case 17: PInfo[playerid][XPToRankUp] = 7000;
	    case 18: PInfo[playerid][XPToRankUp] = 8000;
	    case 19: PInfo[playerid][XPToRankUp] = 9000;
	    case 20: PInfo[playerid][XPToRankUp] = 10000;
	    case 21: PInfo[playerid][XPToRankUp] = 12500;
	    case 22: PInfo[playerid][XPToRankUp] = 15000;
	    case 23: PInfo[playerid][XPToRankUp] = 17500;
	    case 24: PInfo[playerid][XPToRankUp] = 20000;
	    case 25: PInfo[playerid][XPToRankUp] = 22500;
	    case 26: PInfo[playerid][XPToRankUp] = 25000;
	    case 27: PInfo[playerid][XPToRankUp] = 27500;
	    case 28: PInfo[playerid][XPToRankUp] = 30000;
	    case 29: PInfo[playerid][XPToRankUp] = 32500;
	    case 30: PInfo[playerid][XPToRankUp] = 35000;
	    case 31: PInfo[playerid][XPToRankUp] = 40000;
	    case 32: PInfo[playerid][XPToRankUp] = 45000;
	    case 33: PInfo[playerid][XPToRankUp] = 50000;
	    case 34: PInfo[playerid][XPToRankUp] = 55000;
	    case 35: PInfo[playerid][XPToRankUp] = 60000;
	    case 36: PInfo[playerid][XPToRankUp] = 65000;
	    case 37: PInfo[playerid][XPToRankUp] = 70000;
	    case 38: PInfo[playerid][XPToRankUp] = 75000;
	    case 39: PInfo[playerid][XPToRankUp] = 80000;
	    case 40: PInfo[playerid][XPToRankUp] = 85000;
	    case 41: PInfo[playerid][XPToRankUp] = 90000;
	    case 42: PInfo[playerid][XPToRankUp] = 95000;
	    case 43: PInfo[playerid][XPToRankUp] = 100000;
	    case 44: PInfo[playerid][XPToRankUp] = 105000;
	    case 45: PInfo[playerid][XPToRankUp] = 110000;
	    case 46: PInfo[playerid][XPToRankUp] = 115000;
	    case 47: PInfo[playerid][XPToRankUp] = 120000;
	    case 48: PInfo[playerid][XPToRankUp] = 125000;
	    case 49: PInfo[playerid][XPToRankUp] = 130000;
	    case 50: PInfo[playerid][XPToRankUp] = 135000;
	}

	if(PInfo[playerid][XP] >= PInfo[playerid][XPToRankUp])
	{
	    GameTextForPlayer(playerid,"~g~~h~RANK UP!",5000,3);
	    PlaySound(playerid,1057);
	    PInfo[playerid][Rank]++;
	    PInfo[playerid][XP] = 0;

	    CheckRankup(playerid, 1);
	    SetPlayerScore(playerid, PInfo[playerid][Rank]);
	}

	if(gw == 1)
	{
	    if(Team[playerid] == ZOMBIE) return 0;
	    switch(PInfo[playerid][Rank])
		{
		    case 1: GivePlayerWeapon(playerid,23,90),GivePlayerWeapon(playerid,25,5);
		    case 2: GivePlayerWeapon(playerid,23,110),GivePlayerWeapon(playerid,25,10);
		    case 3: GivePlayerWeapon(playerid,23,160),GivePlayerWeapon(playerid,7,1),GivePlayerWeapon(playerid,25,15);
		    case 4: GivePlayerWeapon(playerid,23,190),GivePlayerWeapon(playerid,7,1),GivePlayerWeapon(playerid,25,20);
		    case 5: GivePlayerWeapon(playerid,22,100),GivePlayerWeapon(playerid,7,1),GivePlayerWeapon(playerid,25,25);
		    case 6: GivePlayerWeapon(playerid,22,150),GivePlayerWeapon(playerid,7,1),GivePlayerWeapon(playerid,25,30);
		    case 7: GivePlayerWeapon(playerid,22,200),GivePlayerWeapon(playerid,7,1),GivePlayerWeapon(playerid,25,35);
		    case 8: GivePlayerWeapon(playerid,22,250),GivePlayerWeapon(playerid,7,1),GivePlayerWeapon(playerid,25,40);
		    case 9: GivePlayerWeapon(playerid,22,300),GivePlayerWeapon(playerid,6,1),GivePlayerWeapon(playerid,25,45);
		    case 10: GivePlayerWeapon(playerid,22,300),GivePlayerWeapon(playerid,6,1),GivePlayerWeapon(playerid,25,100),GivePlayerWeapon(playerid,33,25);
		    case 11: GivePlayerWeapon(playerid,22,400),GivePlayerWeapon(playerid,6,1),GivePlayerWeapon(playerid,25,150),GivePlayerWeapon(playerid,33,30);
		    case 12: GivePlayerWeapon(playerid,22,500),GivePlayerWeapon(playerid,6,1),GivePlayerWeapon(playerid,25,250),GivePlayerWeapon(playerid,33,35);
		    case 13: GivePlayerWeapon(playerid,22,650),GivePlayerWeapon(playerid,6,1),GivePlayerWeapon(playerid,25,350),GivePlayerWeapon(playerid,33,40);
		    case 14: GivePlayerWeapon(playerid,22,750),GivePlayerWeapon(playerid,5,1),GivePlayerWeapon(playerid,25,350),GivePlayerWeapon(playerid,33,45);
		    case 15: GivePlayerWeapon(playerid,24,100),GivePlayerWeapon(playerid,5,1),GivePlayerWeapon(playerid,25,350),GivePlayerWeapon(playerid,33,50);
		    case 16: GivePlayerWeapon(playerid,24,150),GivePlayerWeapon(playerid,5,1),GivePlayerWeapon(playerid,25,400),GivePlayerWeapon(playerid,33,55);
		    case 17: GivePlayerWeapon(playerid,24,200),GivePlayerWeapon(playerid,5,1),GivePlayerWeapon(playerid,25,450),GivePlayerWeapon(playerid,33,60);
		    case 18: GivePlayerWeapon(playerid,24,250),GivePlayerWeapon(playerid,5,1),GivePlayerWeapon(playerid,25,500),GivePlayerWeapon(playerid,33,65);
		    case 19: GivePlayerWeapon(playerid,24,300),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,25,500),GivePlayerWeapon(playerid,33,70);
		    case 20: GivePlayerWeapon(playerid,24,350),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,25,550),GivePlayerWeapon(playerid,28,120),GivePlayerWeapon(playerid,33,75);
		    case 21: GivePlayerWeapon(playerid,24,400),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,25,600),GivePlayerWeapon(playerid,28,200),GivePlayerWeapon(playerid,33,80);
		    case 22: GivePlayerWeapon(playerid,24,450),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,25,650),GivePlayerWeapon(playerid,28,250),GivePlayerWeapon(playerid,33,85);
		    case 23: GivePlayerWeapon(playerid,24,500),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,25,700),GivePlayerWeapon(playerid,28,300),GivePlayerWeapon(playerid,33,90);
		    case 24: GivePlayerWeapon(playerid,24,550),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,25,750),GivePlayerWeapon(playerid,28,350),GivePlayerWeapon(playerid,33,95);
		    case 25: GivePlayerWeapon(playerid,24,600),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,26,150),GivePlayerWeapon(playerid,28,400),GivePlayerWeapon(playerid,33,100);
		    case 26: GivePlayerWeapon(playerid,24,650),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,26,200),GivePlayerWeapon(playerid,28,450),GivePlayerWeapon(playerid,33,110);
		    case 27: GivePlayerWeapon(playerid,24,700),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,26,250),GivePlayerWeapon(playerid,28,500),GivePlayerWeapon(playerid,33,120);
		    case 28: GivePlayerWeapon(playerid,24,750),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,26,300),GivePlayerWeapon(playerid,28,550),GivePlayerWeapon(playerid,33,130);
		    case 29: GivePlayerWeapon(playerid,24,800),GivePlayerWeapon(playerid,4,1),GivePlayerWeapon(playerid,26,400),GivePlayerWeapon(playerid,28,600),GivePlayerWeapon(playerid,33,140);
		    case 30: GivePlayerWeapon(playerid,24,600),GivePlayerWeapon(playerid,9,1),GivePlayerWeapon(playerid,26,150),GivePlayerWeapon(playerid,32,100),GivePlayerWeapon(playerid,33,150);
			case 31: GivePlayerWeapon(playerid,24,700),GivePlayerWeapon(playerid,9,1),GivePlayerWeapon(playerid,26,200),GivePlayerWeapon(playerid,32,150),GivePlayerWeapon(playerid,33,160);
			case 32: GivePlayerWeapon(playerid,24,800),GivePlayerWeapon(playerid,9,1),GivePlayerWeapon(playerid,26,250),GivePlayerWeapon(playerid,32,200),GivePlayerWeapon(playerid,33,170);
            case 33: GivePlayerWeapon(playerid,24,900),GivePlayerWeapon(playerid,9,1),GivePlayerWeapon(playerid,26,300),GivePlayerWeapon(playerid,32,300),GivePlayerWeapon(playerid,33,180);
            case 34: GivePlayerWeapon(playerid,24,1000),GivePlayerWeapon(playerid,9,1),GivePlayerWeapon(playerid,26,400),GivePlayerWeapon(playerid,32,400),GivePlayerWeapon(playerid,33,190);
            case 35..50: GivePlayerWeapon(playerid,24,700),GivePlayerWeapon(playerid,9,1),GivePlayerWeapon(playerid,27,50),GivePlayerWeapon(playerid,32,150),GivePlayerWeapon(playerid,3,250),GivePlayerWeapon(playerid,30,200);
		}
	}

	if(PInfo[playerid][XP] >= PInfo[playerid][XPToRankUp])
	{
 		PlayerTextDrawTextSize(playerid, XPBox[playerid][1], 541.000000, 0.000000);
	    PlayerTextDrawShow(playerid, XPBox[playerid][1]);

	    format(str, sizeof str, "EXP: %d/%d", PInfo[playerid][XP], PInfo[playerid][XPToRankUp]);
	    PlayerTextDrawSetString(playerid, XPStats[playerid], str);
    } else {
        new Float:sizeX = floatmul(floatdiv(floatsub(541.0, 100.625), PInfo[playerid][XPToRankUp]), PInfo[playerid][XP]);

	    PlayerTextDrawTextSize(playerid, XPBox[playerid][1], sizeX + 100.625, 0.0);
        PlayerTextDrawShow(playerid, XPBox[playerid][1]);

	    format(str, sizeof str, "EXP: %d/%d", PInfo[playerid][XP], PInfo[playerid][XPToRankUp]);
	    PlayerTextDrawSetString(playerid, XPStats[playerid], str);
    }

	SetPlayerScore(playerid,PInfo[playerid][Rank]);
	return 1;
}

function RandomCheckpoint()
{
	new rand = random(16);
	CPID = rand;
	if(RoundEnded == 1) return 0;
	if(rand == 0)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i,1193.094482, -1325.130126, 13.398437,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Saint Hospital!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 1;
		}
	}
	if(rand == 1)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i,1773.7175,-1943.9563,13.5575,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Unity!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 2;
		}
	}
	if(rand == 2)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i,1971.801147, -1219.650878, 25.098840,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Glen Park!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 3;
		}
	}
	if(rand == 3)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i,1156.2579,-851.7327,49.1676,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Vinewood burgershot!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 4;
		}
	}
	if(rand == 4)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i,872.0963,-1223.6838,16.8897,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Movie studio!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 5;
		}
	}
	if(rand == 5)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i,769.8062,-1350.9500,13.5307,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Inter Global!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 6;
		}
	}
	if(rand == 6)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,2731.892089, -1098.996582, 68.357086,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Beach Coast!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 7;
		}
	}
	if(rand == 7)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,199.025299, -1818.954467, 4.365598,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to The Beach!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 8;
		}
	}
	if(rand == 8)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,2492.3152,-1668.8440,13.3438,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Grove Street!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 9;
		}
	}
	if(rand == 9)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i, 384.477996, -2064.791503, 7.835937,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Funfair!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 10;
		}
	}
	if(rand == 10)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,1637.489135, -2142.651611, 3.197722,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Verdant Bluffs!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 11;
		}
	}
	if(rand == 11)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,1701.418579, -1042.517211, 23.906250,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Mulholland!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 12;
		}
	}
	if(rand == 12)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,2224.110595, -1348.704589, 22.448579,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Jefferson Church!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 13;
		}
	}
	if(rand == 13)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,1595.277832, -1619.467163, 6.810605,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to the Police Department!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 14;
		}
	}
	if(rand == 14)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,1079.680053, -1619.005737, 13.936754,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Super Market!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 15;
		}
	}
	if(rand == 15)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    SetPlayerCheckpoint(i,295.127410, -1164.233398, 80.909896,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to the Mansion!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 16;
		}
	}
	SetTimer("CheckCP",1000,false);
	return 1;
}

function CheckCP()
{
	if(CPscleared >= 2)
	{
		new infects;
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    if(PInfo[i][Firstspawn] == 1) continue;
		    if(PlayerState[i] == false) continue;
		    if(Team[i] == ZOMBIE) infects++;
		}

        new MyVar[10], counter = 0;

        for(new i; i < 10; i++)
		{
		    MyVar[i] = -1;
		}

		if(floatround(100.0 * floatdiv(infects, PlayersConnected)) <= 20)
		{
		    foreach(new i:Player)
		    {
		        if(PInfo[i][Rank] >= 5 && Team[i] == HUMAN)
		        {
		            if(counter < 10)
		            {
						MyVar[counter] = i;
						counter++;
					}
		        }
			}
		}

		new type;
		if(counter > 5)
	    {
	        type = 3;
	    }
	    else if(counter <= 2)
	    {
	        type = 0;
	    }
	    else type = 2;

		for(new x=0; x < type; x++)
		{
		    new rand = random(counter);
		    if(MyVar[rand] != -1)
			{
				InfectPlayer(MyVar[rand]);
				SendFMessageToAll(white, "[Auto Balance] "cred"%s has been auto setted to the zombie team.", GetPName(MyVar[rand]));
				MyVar[rand] = -1;
		    }
		}
	}
	if(CPValue >= CPVALUE)
	{
	    CPscleared++;
	    new string2[45];
   		format(string2,sizeof string2,"~w~Checkpoints_cleared____~r~%i~w~/%i",CPscleared, MAX_CP_CLEARED);
   		TextDrawSetString(CPSCleared,string2);
   		TextDrawShowForAll(CPSCleared);
	    for(new i; i < MAX_PLAYERS; i++)
	    {
     		new cptext[35];
	        format(cptext,sizeof cptext,"~w~CP's cleared: ~r~~h~%i/%i",CPscleared, MAX_CP_CLEARED);
	        GameTextForPlayer(i, cptext, 4000, 4);

        	if(Team[i] == HUMAN) PInfo[i][Firsttimeincp] = 1;
        	if(IsPlayerInCheckpoint(i) && Team[i] == HUMAN)
        	{
        	    if(Team[i] == ZOMBIE) continue;
        	    HasLeftCP{i} = false;
        		SendClientMessage(i,white,"** "cred"The military seems to be leaving, so should you.");
				PlaySound(i,1083);
				GivePlayerXP(i);
				CheckRankup(i);
				PInfo[i][CPCleared]++;
				CP_Activated = 0;
       		}
       		DisablePlayerCheckpoint(i);
   		}
   		SetTimer("RandomCheckpoint",CPTIME,false);
   		CPID = -1;
   		CPValue = 0;
   		return 1;
	}
	else
	{
	    new Float:health;
	    for(new i; i < MAX_PLAYERS; i++)
	    {
	        if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
	        if(Team[i] == ZOMBIE) continue;
	        if(IsPlayerInCheckpoint(i))
	        {
	            CPValue++;
		        GetPlayerHealth(i,health);
		        if(health < 100)
		        {
		            SetPlayerHealth(i,health+5);
		            GetPlayerHealth(i,health);
		            if(health > 100.0) SetPlayerHealth(i,100.0);
		        }
	        }
	    }
	    if(CPValue >= CPVALUE)
		{
		    CPscleared++;
		    new string2[45];
	   		format(string2,sizeof string2,"~w~Checkpoints_cleared____~r~%i~w~/%i", CPscleared, MAX_CP_CLEARED);
	   		TextDrawSetString(CPSCleared,string2);
	   		TextDrawShowForAll(CPSCleared);
		    for(new i; i < MAX_PLAYERS; i++)
		    {
		        if(!IsPlayerConnected(i)) continue;
				if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;

		        new cptext[35];
		        format(cptext,sizeof cptext,"~w~CP's cleared: ~r~~h~%i/%i",CPscleared, MAX_CP_CLEARED);
		        GameTextForPlayer(i, cptext, 4000, 4);

	        	if(Team[i] == HUMAN) PInfo[i][Firsttimeincp] = 1;
	        	if(IsPlayerInCheckpoint(i) && Team[i] == HUMAN)
	        	{
	        	    if(Team[i] == ZOMBIE) continue;
	        		SendClientMessage(i,white,"** "cred"The military seems to be leaving, so should you.");
					PlaySound(i,1083);
					GivePlayerXP(i);
					CheckRankup(i);
					PInfo[i][CPCleared]++;
					CP_Activated = 0;
	       		}
	       		DisablePlayerCheckpoint(i);
	   		}
	   		if(Extra3CPs == 0)
		   		SetTimer("RandomCheckpoint",CPTIME,false);
			else
			    SetTimer("Random3Checkpoints",CPTIME,false);
	   		CPID = -1;
	   		CPValue = 0;
	   		return 1;
		}
	}
	return SetTimer("CheckCP",1000,false);
}

stock SetPlayerCP(playerid)
{
	if(CPID == -1) return 1;
	else if(CPID == 0)
	{
 		SetPlayerCheckpoint(playerid,1193.094482, -1325.130126, 13.398437,20.0);
	}
	else if(CPID == 1)
	{
 		SetPlayerCheckpoint(playerid,1773.7175,-1943.9563,13.5575,20.0);
	}
    else if(CPID == 2)
	{
 		SetPlayerCheckpoint(playerid,1971.801147, -1219.650878, 25.098840,20.0);
	}
	else if(CPID == 3)
	{
 		SetPlayerCheckpoint(playerid,1156.2579,-851.7327,49.1676,20.0);
	}
    else if(CPID == 4)
	{
 		SetPlayerCheckpoint(playerid,872.0963,-1223.6838,16.8897,20.0);
	}
	else if(CPID == 5)
	{
 		SetPlayerCheckpoint(playerid,769.8062,-1350.9500,13.5307,20.0);
	}
 	else if(CPID == 6)
	{
 		SetPlayerCheckpoint(playerid,2731.892089, -1098.996582, 68.357086,20.0);
	}
	else if(CPID == 7)
	{
 		SetPlayerCheckpoint(playerid,199.025299, -1818.954467, 4.365598,20.0);
	}
	else if(CPID == 8)
	{
 		SetPlayerCheckpoint(playerid,2492.3152,-1668.8440,13.3438,20.0);
	}
	else if(CPID == 9)
	{
 		SetPlayerCheckpoint(playerid,384.477996, -2064.791503, 7.835937,20.0);
	}
	else if(CPID == 10)
	{
 		SetPlayerCheckpoint(playerid,1632.305908, -2150.351562, 13.554687,20.0);
	}
	else if(CPID == 11)
	{
 		SetPlayerCheckpoint(playerid,1701.418579, -1042.517211, 23.906250,20.0);
	}
	else if(CPID == 12)
	{
 		SetPlayerCheckpoint(playerid,2224.110595, -1348.704589, 22.448579,20.0);
	}
	else if(CPID == 13)
	{
 		SetPlayerCheckpoint(playerid,1595.277832, -1619.467163, 6.810605,20.0);
	}
	else if(CPID == 14)
	{
 		SetPlayerCheckpoint(playerid,1079.680053, -1619.005737, 13.936754,20.0);
	}
	else if(CPID == 15)
	{
 		SetPlayerCheckpoint(playerid,295.127410, -1164.233398, 80.909896,20.0);
	}
	return 1;
}

function ShowPlayerHumanPerks(playerid)
{
	if(PInfo[playerid][Rank] == 1) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone","Choose","Cancel");
	if(PInfo[playerid][Rank] == 2) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds","Choose","Cancel");
	if(PInfo[playerid][Rank] == 3) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel ","Choose","Cancel");
	if(PInfo[playerid][Rank] == 4) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil ","Choose","Cancel");
	if(PInfo[playerid][Rank] == 5) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades ","Choose","Cancel");
	if(PInfo[playerid][Rank] == 6) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage","Choose","Cancel");
	if(PInfo[playerid][Rank] == 7) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run","Choose","Cancel");
	if(PInfo[playerid][Rank] == 8) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic","Choose","Cancel");
	if(PInfo[playerid][Rank] == 9) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina","Choose","Cancel");
	if(PInfo[playerid][Rank] == 10) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait","Choose","Cancel");
	if(PInfo[playerid][Rank] == 11) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode","Choose","Cancel");
	if(PInfo[playerid][Rank] == 12) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic","Choose","Cancel");
	if(PInfo[playerid][Rank] == 13) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo","Choose","Cancel");
	if(PInfo[playerid][Rank] == 14) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo \n14\tField Doctor","Choose","Cancel");
 	if(PInfo[playerid][Rank] == 15) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo \n14\tField Doctor \n15\tRocket Boots","Choose","Cancel");
	if(PInfo[playerid][Rank] == 16) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo \n14\tField Doctor \n15\tRocket Boots \n16\tHoming Beacon","Choose","Cancel");
	if(PInfo[playerid][Rank] == 17) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo \n14\tField Doctor \n15\tRocket Boots \n16\tHoming Beacon \n17\tMaster Mechanic","Choose","Cancel");
	if(PInfo[playerid][Rank] == 18) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo \n14\tField Doctor \n15\tRocket Boots \n16\tHoming Beacon \n17\tMaster Mechanic \n18\tFlame Rounds","Choose","Cancel");
	if(PInfo[playerid][Rank] == 19) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo \n14\tField Doctor \n15\tRocket Boots \n16\tHoming Beacon \n17\tMaster Mechanic \n18\tFlame Rounds \n19\tLucky charm","Choose","Cancel");
	if(PInfo[playerid][Rank] == 20) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo \n14\tField Doctor \n15\tRocket Boots \n16\tHoming Beacon \n17\tMaster Mechanic \n18\tFlame Rounds \n19\tLucky charm \n20\tGrenades","Choose","Cancel");
	if(PInfo[playerid][Rank] >= 21) return ShowPlayerDialog(playerid,Humanperksdialog,2,"Survivor perks","1\tNone\n2\tExtra meds \n3\tExtra fuel \n4\tExtra oil \n5\tFlashbang Grenades \
	\n6\tLess BiTE Damage \n7\tBurst Run \n8\tMedic \n9\tMore stamina \n10\tZombie Bait \n11\tStealth Mode \n12\tMechanic \n13\tMore ammo \n14\tField Doctor \n15\tRocket Boots \n16\tHoming Beacon \n17\tMaster Mechanic \n18\tFlame Rounds \n19\tLucky charm \n20\tGrenades \
	\n21\tFire Punch","Choose","Cancel");
	return 1;
}

function ShowPlayerZombiePerks(playerid)
{
	if(PInfo[playerid][Rank] == 1) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone","Choose","Cancel");
	if(PInfo[playerid][Rank] == 2) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite","Choose","Cancel");
	if(PInfo[playerid][Rank] == 3) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger","Choose","Cancel");
	if(PInfo[playerid][Rank] == 4) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite","Choose","Cancel");
	if(PInfo[playerid][Rank] == 5) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper","Choose","Cancel");
	if(PInfo[playerid][Rank] == 6) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode","Choose","Cancel");
	if(PInfo[playerid][Rank] == 7) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch","Choose","Cancel");
	if(PInfo[playerid][Rank] == 8) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter","Choose","Cancel");
	if(PInfo[playerid][Rank] == 9) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer","Choose","Cancel");
	if(PInfo[playerid][Rank] == 10) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run","Choose","Cancel");
	if(PInfo[playerid][Rank] == 11) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite","Choose","Cancel");
	if(PInfo[playerid][Rank] == 12) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper","Choose","Cancel");
	if(PInfo[playerid][Rank] == 13) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp","Choose","Cancel");
	if(PInfo[playerid][Rank] == 14) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp \n14\tMore Refreshing Bite","Choose","Cancel");
	if(PInfo[playerid][Rank] == 15) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp \n14\tMore Refreshing Bite \n15\tGod Dig","Choose","Cancel");
	if(PInfo[playerid][Rank] == 16) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp \n14\tMore Refreshing Bite \n15\tGod Dig\n16\tPopping Tires","Choose","Cancel");
	if(PInfo[playerid][Rank] == 17) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp \n14\tMore Refreshing Bite \n15\tGod Dig\n16\tPopping Tires \n17\tHigher Jumper","Choose","Cancel");
	if(PInfo[playerid][Rank] == 18) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp \n14\tMore Refreshing Bite \n15\tGod Dig\n16\tPopping Tires \n17\tHigher Jumper \n18\tRepellent","Choose","Cancel");
	if(PInfo[playerid][Rank] == 19) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp \n14\tMore Refreshing Bite \n15\tGod Dig\n16\tPopping Tires \n17\tHigher Jumper \n18\tRepellent \n19\tRavaging Bite","Choose","Cancel");
	if(PInfo[playerid][Rank] == 20) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp \n14\tMore Refreshing Bite \n15\tGod Dig\n16\tPopping Tires \n17\tHigher Jumper \n18\tRepellent \n19\tRavaging Bite \n20\tSuper scream","Choose","Cancel");
	if(PInfo[playerid][Rank] >= 21) return ShowPlayerDialog(playerid,Zombieperksdialog,2,"Zombie perks","1\tNone\n2\tHard Bite \n3\tDigger \n4\tRefreshing Bite \n5\tJumper \n6\tHide Mode \
	\n7\tHard Punch \n8\tVomiter \n9\tScreamer \n10\tBurst run \n11\tStinger Bite \n12\tBig jumper \n13\tStomp \n14\tMore Refreshing Bite \n15\tGod Dig\n16\tPopping Tires \n17\tHigher Jumper \n18\tRepellent \n19\tRavaging Bite \n20\tSuper scream \n21\tBoomer","Choose","Cancel");
	return 1;
}

function ClearBurstTimer(playerid)
{
	PInfo[playerid][CanBurst] = 1;
	SendClientMessage(playerid,white,"* "cblue"You feel rested enough to burst run.");
	return 1;
}

stock SendNearMessage(playerid,color,text[],range)
{
    new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
    for(new i; i < MAX_PLAYERS;i++)
    {
    	if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
        if(IsPlayerInRangeOfPoint(i,range,x,y,z))
        {
        	SendClientMessage(i,color,text);
   		}
    }
	return 1;
}

stock randomEx(minnum = cellmin,maxnum = cellmax) return random(maxnum - minnum + 1) + minnum;

stock IsVehicleOccupied(vehicleid)
{
	for(new i; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
	    if(Team[i] == ZOMBIE) continue;
    	if(IsPlayerInVehicle(i, vehicleid))
    	{
  			return 1;
		}
  	}
  	return 0;
}

stock IsVehicleStarted(vehicleid)
{
	if(VehicleStarted[vehicleid] == 1) return 1;
	else return 0;
}

stock StartVehicle(vehicleid,start=1)
{
    new engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
	if(start == 1) SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective),VehicleStarted[vehicleid] = 1;
	else if(start == 0) SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_OFF,lights,alarm,doors,bonnet,boot,objective),VehicleStarted[vehicleid] = 0;
	return 1;
}

UpdateVehicleFuelAndOil(vehicleid)
{
	if(Fuel[vehicleid] <= 0)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~EMPTY");
				GameTextForPlayer(i,"~n~~n~~r~~h~No fuel left!",4000,3);
			}
		}
		StartVehicle(vehicleid,0);
		VehicleStarted[vehicleid] = 0;
	}
	if(Fuel[vehicleid] > 0 && Fuel[vehicleid] <= 10)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~l");
			}
		}
	}
	if(Fuel[vehicleid] > 10 && Fuel[vehicleid] <= 20)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll");
			}
		}
	}
	if(Fuel[vehicleid] > 20 && Fuel[vehicleid]<= 30)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll~y~l");
			}
		}
	}
	if(Fuel[vehicleid] > 30 && Fuel[vehicleid] <= 40)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll~y~ll");
			}
		}
	}
	if(Fuel[vehicleid] > 40 && Fuel[vehicleid] <= 50)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll~y~lll");
			}
		}
	}
	if(Fuel[vehicleid] > 50 && Fuel[vehicleid] <= 60)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll~y~llll");
			}
		}
	}
	if(Fuel[vehicleid] > 60 && Fuel[vehicleid] <= 70)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll~y~lllll");
			}
		}
	}
	if(Fuel[vehicleid] > 70 && Fuel[vehicleid] <= 80)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll~y~llllll");
			}
		}
	}
	if(Fuel[vehicleid] > 80 && Fuel[vehicleid] <= 90)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll~y~llllll~g~~h~l");
			}
		}
	}
	if(Fuel[vehicleid] > 90 && Fuel[vehicleid] <= 100)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(FuelTD[i],"Fuel: ~r~~h~ll~y~llllll~g~~h~ll");
			}
		}
	}

	if(Oil[vehicleid] <= 0)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~EMPTY");
				GameTextForPlayer(i,"~n~~n~~r~~h~No oil left!",4000,3);
			}
		}
		StartVehicle(vehicleid,0);
		VehicleStarted[vehicleid] = 0;
	}
	if(Oil[vehicleid] > 0 && Oil[vehicleid] <= 10)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~l");
			}
		}
	}
	if(Oil[vehicleid] > 10 && Oil[vehicleid] <= 20)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll");
			}
		}
	}
	if(Oil[vehicleid] > 20 && Oil[vehicleid] <= 30)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll~y~l");
			}
		}
	}
	if(Oil[vehicleid] > 30 && Oil[vehicleid] <= 40)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll~y~ll");
			}
		}
	}
	if(Oil[vehicleid] > 40 && Oil[vehicleid] <= 50)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll~y~lll");
			}
		}
	}
	if(Oil[vehicleid] > 50 && Oil[vehicleid] <= 60)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll~y~llll");
			}
		}
	}
	if(Oil[vehicleid] > 60 && Oil[vehicleid] <= 70)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll~y~lllll");
			}
		}
	}
	if(Oil[vehicleid] > 70 && Oil[vehicleid] <= 80)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll~y~llllll");
			}
		}
	}
	if(Oil[vehicleid] > 80 && Oil[vehicleid] <= 90)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll~y~llllll~g~~h~l");
			}
		}
	}
	if(Oil[vehicleid] > 90 && Oil[vehicleid] <= 100)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
		    if(!IsPlayerConnected(i)) continue;
		    if(Team[i] == ZOMBIE) continue;
			if(IsPlayerInVehicle(i,vehicleid))
			{
				TextDrawSetString(OilTD[i],"Oil: ~r~~h~ll~y~llllll~g~~h~ll");
			}
		}
	}
	return 1;
}

function Startvehicle(playerid)
{
	if(PInfo[playerid][SPerk] == 16)
	{
		if(Fuel[GetPlayerVehicleID(playerid)] == 0) return SendClientMessage(playerid,red,"There's no fuel in this car!"),PInfo[playerid][StartCar] = 0;
	    if(Oil[GetPlayerVehicleID(playerid)] == 0) return SendClientMessage(playerid,red,"There's no oil in this car!"),PInfo[playerid][StartCar] = 0;
	    SendClientMessage(playerid,white,"* "corange"The vehicle has successfully started");
	    StartVehicle(GetPlayerVehicleID(playerid),1);
	    PInfo[playerid][StartCar] = 0;
	    VehicleStarted[GetPlayerVehicleID(playerid)] = 1;
	}
	else
	{
		new rand = random(2);
		if(rand == 0) return SendClientMessage(playerid,white,"* "cred"The car has failed to start."),PInfo[playerid][StartCar] = 0;
		else
		{
		    if(Fuel[GetPlayerVehicleID(playerid)] == 0) return SendClientMessage(playerid,red,"There's no fuel in this car!"),PInfo[playerid][StartCar] = 0;
		    if(Oil[GetPlayerVehicleID(playerid)] == 0) return SendClientMessage(playerid,red,"There's no oil in this car!"),PInfo[playerid][StartCar] = 0;
		    SendClientMessage(playerid,white,"* "corange"The vehicle has successfully started");
		    StartVehicle(GetPlayerVehicleID(playerid),1);
		    PInfo[playerid][StartCar] = 0;
		    VehicleStarted[GetPlayerVehicleID(playerid)] = 1;
		}
	}
	return 1;
}

stock LoadStaticVehicles()
{
	new File:file_ptr;
	new line[256];
	new var_from_line[64];
	new vehicletype;
	new Float:SpawnX;
	new Float:SpawnY;
	new Float:SpawnZ;
	new Float:SpawnRot;
    new Color1, Color2;
	new index;
	new id;
	new vehicles_loaded;

	file_ptr = fopen("Admin/Allcars.txt",filemode:io_read);
	if(!file_ptr) return 0;

	vehicles_loaded = 0;

	while(fread(file_ptr,line,256) > 0)
	{
	    index = 0;

  		index = token_by_delim(line,var_from_line,',',index);
  		if(index == (-1)) continue;
  		vehicletype = strval(var_from_line);
   		if(vehicletype < 400 || vehicletype > 611) continue;

  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		SpawnX = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		SpawnY = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		SpawnZ = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		SpawnRot = floatstr(var_from_line);

  		index = token_by_delim(line,var_from_line,',',index+1);
  		if(index == (-1)) continue;
  		Color1 = strval(var_from_line);

  		index = token_by_delim(line,var_from_line,';',index+1);
  		if(index == (-1)) continue;
  		Color2 = strval(var_from_line);


  		id = CreateVehicle(vehicletype,SpawnX,SpawnY,SpawnZ+2,SpawnRot,Color1,Color2, 600000);

		vehicles_loaded++;
		if(vehicletype == 409) ChangeVehicleColor(id,0,0);
		if(vehicletype == 571) ChangeVehicleColor(id,0,5);
		if(vehicletype == 571) ChangeVehicleColor(id,0,5);
	}

	fclose(file_ptr);
	printf("Loaded %d vehicles",vehicles_loaded);
	return vehicles_loaded;
}

/*stock token_by_delim(const string[], return_str[], delim, start_index)
{
	new x=0;
	while(string[start_index] != EOS && string[start_index] != delim) {
	    return_str[x] = string[start_index];
	    x++;
	    start_index++;
	}
	return_str[x] = EOS;
	if(string[start_index] == EOS) start_index = (-1);
	return start_index;
}*/

public OnPlayerUseItem(playerid,ItemName[])
{
	new string[256];
  	if(!strcmp(ItemName,"Large Medical Kits",true))
  	{
  	    if(PInfo[playerid][SPerk] == 7 || PInfo[playerid][SPerk] == 13)
  	    {
  	        new id = -1;
  	        new Float:x,Float:y,Float:z;
			for(new i; i < MAX_PLAYERS;i++)
			{
			    if(!IsPlayerConnected(i)) continue;
			    if(Team[i] == ZOMBIE) continue;
				GetPlayerPos(playerid,x,y,z);
				if(!IsPlayerInRangeOfPoint(i,2.0,x,y,z)) continue;
				if(i == playerid) continue;
				id = i;
			}
			if(id == -1) return SendClientMessage(playerid,white,"» "cred"You aren't near a survivor!");
			new Float:health;
			GetPlayerHealth(id,health);
			if(health >= 100.0) return SendClientMessage(playerid,white,"* "cred"This player does not need medical atention.");
            SetPlayerHealth(id,health+50.0);
            format(string,sizeof string,""cjam"%s(%i) has assisted %s(%i) with a large medical kit.",GetPName(playerid),playerid,GetPName(id),id);
			SendNearMessage(playerid,white,string,20);
			RemoveItem(playerid,"Large Medical Kits",1);
			GetPlayerHealth(id,health);
            if(health > 100.0) SetPlayerHealth(id,100.0);
		}
		else
		{
		    new Float:health;
			GetPlayerHealth(playerid,health);
		    if(health >= 100.0) return SendClientMessage(playerid, white, "* "cred"You don't need to use a med kit.");
		    if(health > 100.0) return SetPlayerHealth(playerid, 100.0);
	        RemoveItem(playerid,"Large Medical Kits",1);
	        format(string,sizeof string,""cjam"%s(%i) has taken a large medical kit.",GetPName(playerid),playerid);
			SendNearMessage(playerid,white,string,20);
			if(PInfo[playerid][SPerk] != 1) SetPlayerHealth(playerid,health+50.0);
			else SetPlayerHealth(playerid,health+55.0);
		}
  	}
  	if(!strcmp(ItemName,"Medium Medical Kits",true))
  	{
  	    if(PInfo[playerid][SPerk] == 7 || PInfo[playerid][SPerk] == 13)
  	    {
  	        new id = -1;
  	        new Float:x,Float:y,Float:z;
			for(new i; i < MAX_PLAYERS;i++)
			{
			    if(!IsPlayerConnected(i)) continue;
			    if(Team[i] == ZOMBIE) continue;
				GetPlayerPos(playerid,x,y,z);
				if(!IsPlayerInRangeOfPoint(i,2.0,x,y,z)) continue;
				if(i == playerid) continue;
				id = i;
			}
			if(id == -1) return SendClientMessage(playerid,white,"» "cred"You aren't near a survivor!");
			new Float:health;
			GetPlayerHealth(id,health);
			if(health >= 100.0) return SendClientMessage(playerid,white,"* "cred"This player does not need medical atention.");
            SetPlayerHealth(id,health+20.0);
            format(string,sizeof string,""cjam"%s(%i) has assisted %s(%i) with a medium medical kit.",GetPName(playerid),playerid,GetPName(id),id);
			SendNearMessage(playerid,white,string,20);
			RemoveItem(playerid,"Medium Medical Kits",1);
			GetPlayerHealth(id,health);
            if(health > 100.0) SetPlayerHealth(id,100.0);
		}
		else
		{
  			new Float:health;
			GetPlayerHealth(playerid,health);
		    if(health >= 100.0) return SendClientMessage(playerid, white, "* "cred"You don't need to use a med kit.");
		    if(health > 100.0) return SetPlayerHealth(playerid, 100.0);
	        RemoveItem(playerid,"Medium Medical Kits",1);
	        format(string,sizeof string,""cjam"%s(%i) has taken a medium medical kit.",GetPName(playerid),playerid);
			SendNearMessage(playerid,white,string,20);
			if(PInfo[playerid][SPerk] != 1) SetPlayerHealth(playerid,health+20.0);
			else SetPlayerHealth(playerid,health+25.0);
		}
  	}
  	if(!strcmp(ItemName,"Small Medical Kits",true))
  	{
  	    if(PInfo[playerid][SPerk] == 7 || PInfo[playerid][SPerk] == 13)
  	    {
  	        new id = -1;
  	        new Float:x,Float:y,Float:z;
			for(new i; i < MAX_PLAYERS;i++)
			{
			    if(!IsPlayerConnected(i)) continue;
			    if(Team[i] == ZOMBIE) continue;
				GetPlayerPos(playerid,x,y,z);
				if(!IsPlayerInRangeOfPoint(i,2.0,x,y,z)) continue;
				if(i == playerid) continue;
				id = i;
			}
			if(id == -1) return SendClientMessage(playerid,white,"» "cred"You aren't near a survivor!");
			new Float:health;
			GetPlayerHealth(id,health);
			if(health >= 100.0) return SendClientMessage(playerid,white,"* "cred"This player does not need medical atention."),SetPlayerHealth(id,100.0);
            SetPlayerHealth(id,health+8.0);
            format(string,sizeof string,""cjam"%s(%i) has assisted %s(%i) with a small medical kit.",GetPName(playerid),playerid,GetPName(id),id);
			SendNearMessage(playerid,white,string,20);
			RemoveItem(playerid,"Small Medical Kits",1);
			GetPlayerHealth(id,health);
            if(health > 100.0) SetPlayerHealth(id,100.0);
		}
		else
		{
  			new Float:health;
			GetPlayerHealth(playerid,health);
		    if(health >= 100.0) return SendClientMessage(playerid, white, "* "cred"You don't need to use a med kit.");
		    if(health > 100.0) return SetPlayerHealth(playerid, 100.0);
	        RemoveItem(playerid,"Small Medical Kits",1);
	        format(string,sizeof string,""cjam"%s(%i) has taken a small medical kit.",GetPName(playerid),playerid);
			SendNearMessage(playerid,white,string,20);
			if(PInfo[playerid][SPerk] != 1) SetPlayerHealth(playerid,health+3.0);
			else SetPlayerHealth(playerid,health+8.0);
		}
  	}
    if(!strcmp(ItemName,"Fuel",true))
    {
        new counter = 0;
	    new result;
	    for(new i; i != MAX_VEHICLES; i++)
	    {
	        new dist = CheckPlayerDistanceToVehicle(2.5, playerid, i);
	        if(dist)
	        {
	            result = i;
	            counter++;
	        }
	    }
	    switch(counter)
	    {
	        case 0: return SendClientMessage(playerid, white, "» "cred"You aren't nearby of a vehicle!");
	        case 1:
	        {
	            if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, white, "» "cred"You can't refill inside the car.");

		        if(Fuel[result] >= 100)
				{
					SendFMessage(playerid,white,"» "cred"This %s does not need anymore fuel.", GetVehicleName(result));
					Fuel[result] = 100;
					return 1;
				}

		        RemoveItem(playerid,"Fuel",1);
		        format(string,sizeof string,""cjam"%s(%i) has added some fuel to his vehicle.",GetPName(playerid),playerid);
		        SendNearMessage(playerid,white,string,20);

				if(PInfo[playerid][SPerk] == 2) Fuel[result]+=12;
				else Fuel[result]+=7;

				UpdateVehicleFuelAndOil(result);
			}
        	default:
	        {
	            SendClientMessage(playerid, white, "» "cred"There are more than a car nearby.");
	            return 1;
	        }
	    }
    }
    if(!strcmp(ItemName,"Oil",true))
    {
        new counter = 0;
	    new result;
	    for(new i; i != MAX_VEHICLES; i++)
	    {
	        new dist = CheckPlayerDistanceToVehicle(2.5, playerid, i);
	        if(dist)
	        {
	            result = i;
	            counter++;
	        }
	    }
	    switch(counter)
	    {
	        case 0: return SendClientMessage(playerid, white, "» "cred"You aren't nearby of a vehicle!");
	        case 1:
	        {
	            if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, white, "» "cred"You can't refill inside the car.");

		        if(Oil[result] >= 100)
				{
					SendFMessage(playerid, white, "» "cred"This %s does not need anymore oil.", GetVehicleName(result));
					Oil[result] = 100;
					return 1;
				}

		        RemoveItem(playerid,"Oil",1);
                format(string,sizeof string,""cjam"%s(%i) has added some oil to his vehicle.",GetPName(playerid),playerid);
		        SendNearMessage(playerid,white,string,20);

				if(PInfo[playerid][SPerk] == 3) Oil[result]+=12;
				else Oil[result]+=7;

				UpdateVehicleFuelAndOil(result);
            }
            default:
	        {
	            SendClientMessage(playerid, white, "» "cred"There are more than a car nearby.");
	            return 1;
	        }
	    }
	}
    if(!strcmp(ItemName,"Dizzy Pills",true))
    {
        if(PInfo[playerid][SPerk] != 13)
        {
        	PInfo[playerid][TokeDizzy] = 1;
        	RemoveItem(playerid,"Dizzy Pills",1);
        	format(string,sizeof string,""cjam"%s(%i) has taken some dizzy away pills.",GetPName(playerid),playerid);
        	SendNearMessage(playerid,white,string,20);
        	SetPlayerDrunkLevel(playerid,0);
  		}
  		else
  		{
  		    new id = -1;
  		    new Float:x,Float:y,Float:z;
			GetPlayerPos(playerid,x,y,z);
			for(new i; i < MAX_PLAYERS;i++)
			{
			    if(i == playerid) continue;
			    if(!IsPlayerConnected(i)) continue;
			    if(Team[i] == ZOMBIE) continue;
			    if(IsPlayerInRangeOfPoint(i,2.0,x,y,z)) id = i;
			    else continue;
			}
			if(id == -1) return SendClientMessage(playerid,red,"You aren't near a survivor to assist!");
			PInfo[id][TokeDizzy] = 1;
        	format(string,sizeof string,""cjam"%s(%i) has assisted %s(%i) some dizzy away pills.",GetPName(playerid),playerid,GetPName(id),id);
        	SendNearMessage(playerid,white,string,20);
  		}
    }
    if(!strcmp(ItemName,"Flashlight",true))
    {
        if(PInfo[playerid][Lighton] == 1)
        {
        	RemovePlayerAttachedObject(playerid,3);
        	RemovePlayerAttachedObject(playerid,4);
        	PInfo[playerid][Lighton] = 0;
 			format(string,sizeof string,""cjam"%s has turned off his flashlight.",GetPName(playerid));
			SendNearMessage(playerid,white,string,30);
        }
        else
        {
        	SetPlayerAttachedObject(playerid, 3, 18656, 5, 0.1, 0.038, -0.1, -90, 180, 0, 0.03, 0.03, 0.03);
			SetPlayerAttachedObject(playerid, 4, 18641, 5, 0.1, 0.02, -0.05, 0, 0, 0, 1, 1, 1);
        	PInfo[playerid][Lighton] = 1;
 			format(string,sizeof string,""cjam"%s has turned on his flashlight.",GetPName(playerid));
			SendNearMessage(playerid,white,string,30);
       	}
    }
	if(!strcmp(ItemName,"Molotovs Guide"))
	{
	    RemoveItem(playerid,"Molotovs Guide",1);
	    new rand = random(2);
		switch(rand)
		{
		    case 0: SendClientMessage(playerid,white,"* "corange"Head over to Pig Pen to get some alcohol"),Mission[playerid] = 1, MissionPlace[playerid][0] = 1, MissionPlace[playerid][1] = 1,SetPlayerMapIcon(playerid,1,Locations[0][3],Locations[0][4],Locations[0][5],62,0,MAPICON_GLOBAL);
			case 1: SendClientMessage(playerid,white,"* "corange"Head over to Alhambra to get some alcohol"),Mission[playerid] = 1, MissionPlace[playerid][0] = 2, MissionPlace[playerid][1] = 1,SetPlayerMapIcon(playerid,1,Locations[1][3],Locations[1][4],Locations[1][5],62,0,MAPICON_GLOBAL);
		}
	}
	if(!strcmp(ItemName,"Bouncing Bettys Guide"))
	{
	    if(Mission[playerid] == 1) return SendClientMessage(playerid,red,"» Please finish your molotovs mission!");
	    RemoveItem(playerid,"Bouncing Bettys Guide",1);
	    new rand = random(2);
		switch(rand)
		{
		    case 0: SendClientMessage(playerid,white,"* "corange"Head over to Pig Pen to get some ethanol"),Mission[playerid] = 2, MissionPlace[playerid][0] = 1, MissionPlace[playerid][1] = 1,SetPlayerMapIcon(playerid,1,Locations[0][3],Locations[0][4],Locations[0][5],62,0,MAPICON_GLOBAL);
			case 1: SendClientMessage(playerid,white,"* "corange"Head over to Alhambra to get some ethanol"),Mission[playerid] = 2, MissionPlace[playerid][0] = 2, MissionPlace[playerid][1] = 1,SetPlayerMapIcon(playerid,1,Locations[1][3],Locations[1][4],Locations[1][5],62,0,MAPICON_GLOBAL);
		}
	}
  	return 0;
}

stock CheckPlayerDistanceToVehicle(Float:radi, playerid, vehicleid)
{
	if(IsPlayerConnected(playerid))
	{
	    new Float:PX2,Float:PY2,Float:PZ2,Float:X2,Float:Y2,Float:Z2;
	    GetPlayerPos(playerid,PX2,PY2,PZ2);
	    GetVehiclePos(vehicleid, X2,Y2,Z2);
	    new Float:Distance = (X2-PX2)*(X2-PX2)+(Y2-PY2)*(Y2-PY2)+(Z2-PZ2)*(Z2-PZ2);
	    if(Distance <= radi*radi)
	    {
	        return 1;
	    }
	}
	return 0;
}

function StopBait(playerid)
{
	foreach(new i:Player)
	{
	    if(!IsPlayerConnected(i)) continue;
   		if(PInfo[i][Dead] == 1) continue;
	    if(Team[i] == HUMAN) continue;
		if(IsPlayerInRangeOfPoint(i,15.0,PInfo[playerid][ZX],PInfo[playerid][ZY],PInfo[playerid][ZZ]))
		{
		    ClearAnimations(i,1);
		}
	}
	PInfo[playerid][ZX] = 0.0;
	DestroyObject(PInfo[playerid][ZObject]);
	PInfo[playerid][ZombieBait] = 0;
	return 1;
}

function UseBaitAgain(playerid)
{
	if(PInfo[playerid][ZombieBait] == 1) PInfo[playerid][ZombieBait] = 0;
	return 1;
}

function CanUseFiremode(playerid)
{
	PInfo[playerid][FireMode] = 0;
	return 1;
}

function AffectFire(playerid,id)
{
	if(PInfo[playerid][OnFire] == 5)
	{
		PInfo[playerid][OnFire] = 0;
		DestroyObject(PInfo[playerid][FireObject]);
	}
	else
	{
	    SetTimerEx("AffectFire",500,false,"ii",playerid,id);
        new Float:health;
		GetPlayerHealth(playerid,health);
		SetPlayerHealth(playerid,health-8);
		GetPlayerHealth(playerid,health);
		PInfo[playerid][OnFire]++;
	}
	return 1;
}


stock SaveIn(filename[],text[],displaydate)
{
	new File:Lfile;
	new filepath[256];
	new string[256];
	new year,month,day;
	new hour,minute,second;

	getdate(year,month,day);
	gettime(hour,minute,second);
	format(filepath,sizeof(filepath),"Admin/Logs/%s.txt",filename);
	if(!INI_Exist(filepath))
	{
	    INI_Open(filepath);
 	}
	Lfile = fopen(filepath,io_append);
	if(displaydate == 1)
	{
		format(string,sizeof(string),"[%02d/%02d/%02d | %02d:%02d:%02d] %s\r\n",day,month,year,hour,minute,second,text);
		fwrite(Lfile,string);
		fclose(Lfile);
	}
	else if(displaydate == 0)
	{
	    format(string,sizeof(string),"%s\r\n",text);
		fwrite(Lfile,string);
		fclose(Lfile);
	}
	return 1;
}

GetWeaponType(weaponid)
{
	switch(weaponid)
	{
	    case 22,23,24,26,28,32:
	        return WEAPON_TYPE_LIGHT;

		case 3,4,16,17,18,39,10,11,12,13,14,40,41:
		    return WEAPON_TYPE_MELEE;

		case 2,5,6,7,8,9,25,27,29,30,31,33,34,35,36,37,38:
		    return WEAPON_TYPE_HEAVY;
	}
	return WEAPON_TYPE_NONE;
}

stock GetWeaponModel(weaponid)
{
	switch(weaponid)
	{
	    case 1:
	        return 331;

		case 2..8:
		    return weaponid+331;

        case 9:
		    return 341;

		case 10..15:
			return weaponid+311;

		case 16..18:
		    return weaponid+326;

		case 22..29:
		    return weaponid+324;

		case 30,31:
		    return weaponid+325;

		case 32:
		    return 372;

		case 33..45:
		    return weaponid+324;

		case 46:
		    return 371;
	}
	return 0;
}

function UnloadMusic(playerid)
{
    StopAudioStreamForPlayer(playerid);
    return 1;
}

/*function RandomSounds()
{
    for(new i; i < MAX_PLAYERS;i++)
	{
        if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
	    new rand2 = random(5);
		if(rand2 == 1){ PlayAudioStream(i,"http://k004.kiwi6.com/hotlink/oy385dubfq/1.mp3",4)}
		else if(rand2 == 2){ PlayAudioStream(i,"http://k004.kiwi6.com/hotlink/qzgzjb4lqa/2.mp3",4)}
		else if(rand2 == 3){ PlayAudioStream(i,"http://k004.kiwi6.com/hotlink/oy385dubfq/1.mp3",4)}
		else if(rand2 == 4){ PlayAudioStream(i,"http://k004.kiwi6.com/hotlink/qzgzjb4lqa/2.mp3",4)}
	}
	return 1;
}*/

stock TurnPlayerFaceToPos(playerid, Float:x, Float:y)
{
    new Float:angle;
    new Float:misc = 5.0;
    new Float:ix, Float:iy, Float:iz;
    GetPlayerPos(playerid, ix, iy, iz);
    angle = 180.0-atan2(ix-x,iy-y);
    angle += misc;
    misc *= -1;
    SetPlayerFacingAngle(playerid, angle+misc);
}

stock IsPlayerBehindPlayer(playerid, targetid, Float:dOffset)
{

	new
	    Float:pa,
	    Float:ta;

	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;

	GetPlayerFacingAngle(playerid, pa);
	GetPlayerFacingAngle(targetid, ta);

	if(AngleInRangeOfAngle(pa, ta, dOffset) && IsPlayerFacingPlayer(playerid, targetid, dOffset)) return true;

	return false;

}

stock SetPlayerToFacePlayer(playerid, targetid)
{

	new
		Float:pX,
		Float:pY,
		Float:pZ,
		Float:X,
		Float:Y,
		Float:Z,
		Float:ang;
	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;
	GetPlayerPos(targetid, X, Y, Z);
	GetPlayerPos(playerid, pX, pY, pZ);
	if( Y > pY ) ang = (-acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
	else if( Y < pY && X < pX ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 450.0);
	else if( Y < pY ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);

	if(X > pX) ang = (floatabs(floatabs(ang) + 180.0));
	else ang = (floatabs(ang) - 180.0);

	SetPlayerFacingAngle(playerid, ang);
 	return 0;
}

stock IsPlayerFacingPlayer(playerid, targetid, Float:dOffset)
{
	new
		Float:pX,
		Float:pY,
		Float:pZ,
		Float:pA,
		Float:X,
		Float:Y,
		Float:Z,
		Float:ang;
	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(targetid)) return 0;
	GetPlayerPos(targetid, pX, pY, pZ);
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, pA);

	if( Y > pY ) ang = (-acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);
	else if( Y < pY && X < pX ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 450.0);
	else if( Y < pY ) ang = (acos((X - pX) / floatsqroot((X - pX)*(X - pX) + (Y - pY)*(Y - pY))) - 90.0);

	if(AngleInRangeOfAngle(-ang, pA, dOffset)) return true;
	return false;
}

stock AngleInRangeOfAngle(Float:a1, Float:a2, Float:range)
{
	a1 -= a2;
	if((a1 < range) && (a1 > -range)) return true;
	return false;
}

function ClearAnim(playerid)
{
	ClearAnimations(playerid,1);
	return 1;
}

function ClearAnim2(playerid)
{
	ClearAnimations(playerid,1);
	TogglePlayerControllable(playerid,1);
	return 1;
}

function RemoveStomp(playerid)
{
	TogglePlayerControllable(playerid,1);
	return 1;
}


function DigToPlayer(playerid,id)
{
    if(IsPlayerNPC(id)) return 1;
	ClearAnimations(playerid);
	new Float:x,Float:y,Float:z;
	GetPlayerPos(id,x,y,z);
	SetPlayerPos(playerid,x,y+2,z+2);
	SetPlayerInterior(playerid,GetPlayerInterior(id));
	return 1;
}

function Marker()
{
    new Float:x,Float:y,Float:z;
    for(new i=0; i < MAX_PLAYERS; i++)
    {
        GetPlayerPos(i, x,y,z);
        if(Team[i] == ZOMBIE)
        {
            if(!IsPlayerInRangeOfPoint(i, 150.0, x,y,z)) continue;
            SetPlayerMarkerForPlayer(i, i, purple);
            for(new f=0; f < MAX_PLAYERS; f++)
            {
                if(Team[f] == HUMAN)
                {
                    if(!IsPlayerInRangeOfPoint(f, 150.0, x, y, z)) continue;
					SetPlayerMarkerForPlayer(i, f, green);
                }
            }
        }
        else if(Team[i] == HUMAN)
        {
            for(new f=0; f < MAX_PLAYERS; f++)
            {
                if(Team[f] == ZOMBIE)
                {
		            if(PInfo[i][Lighton] == 1)
					{
					    if(IsPlayerInRangeOfPoint(f, 250.0, x,y,z))
					    {
							SetPlayerMarkerForPlayer(i, f, purple);
						} else {
						    SetPlayerMarkerForPlayer(i, f, COLOR_INVISIBLE);
						}
					} else {
					    if(IsPlayerInRangeOfPoint(f, 50.0, x,y,z))
					    {
							SetPlayerMarkerForPlayer(i, f, purple);
						} else {
						    SetPlayerMarkerForPlayer(i, f, COLOR_INVISIBLE);
						}
					}
				}
			}
		}
    }
    return 1;
}

function VomitPlayer(playerid)
{
	DestroyObject(PInfo[playerid][Vomit]);
    PInfo[playerid][Vomit] = CreateObject(2908, PInfo[playerid][Vomitx], PInfo[playerid][Vomity], PInfo[playerid][Vomitz]-1.0,0,0,0,200);
    PInfo[playerid][Allowedtovomit] = GetTickCount();
	PInfo[playerid][Vomitmsg] = 0;
	return 1;
}

stock MakeHealthEven(playerid,Float:health)
{
	if(health == 1) return SetPlayerHealth(playerid,2);
	if(health == 3) return SetPlayerHealth(playerid,4);
	if(health == 5) return SetPlayerHealth(playerid,6);
	if(health == 7) return SetPlayerHealth(playerid,8);
	if(health == 9) return SetPlayerHealth(playerid,10);
	if(health == 11) return SetPlayerHealth(playerid,12);
	if(health == 13) return SetPlayerHealth(playerid,14);
	if(health == 15) return SetPlayerHealth(playerid,16);
	if(health == 17) return SetPlayerHealth(playerid,18);
	if(health == 19) return SetPlayerHealth(playerid,20);
	if(health == 21) return SetPlayerHealth(playerid,22);
	if(health == 23) return SetPlayerHealth(playerid,24);
	if(health == 25) return SetPlayerHealth(playerid,26);
	if(health == 27) return SetPlayerHealth(playerid,28);
	if(health == 29) return SetPlayerHealth(playerid,30);
	if(health == 31) return SetPlayerHealth(playerid,32);
	if(health == 33) return SetPlayerHealth(playerid,34);
	if(health == 35) return SetPlayerHealth(playerid,36);
	if(health == 37) return SetPlayerHealth(playerid,38);
	if(health == 39) return SetPlayerHealth(playerid,40);
	if(health == 41) return SetPlayerHealth(playerid,42);
	if(health == 43) return SetPlayerHealth(playerid,44);
	if(health == 45) return SetPlayerHealth(playerid,46);
	if(health == 47) return SetPlayerHealth(playerid,48);
	if(health == 49) return SetPlayerHealth(playerid,50);
	return 1;
}

function FiveSeconds()
{
	new infects;
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
	    if(PInfo[i][Firstspawn] == 1) continue;
	    if(PlayerState[i] == false) continue;
	    if(Team[i] == ZOMBIE) infects++;
	}
	if(infects > 0)
	{
		new string2[24];
		format(string2,sizeof string2,"infection____~r~~h~%i%", floatround(100.0 * floatdiv(infects, PlayersConnected)));
		TextDrawSetString(Infection,string2);

		if(floatround(100.0 * floatdiv(infects, PlayersConnected)) >= 100)
		{
		    if(RoundEnded == 0)
		    {
          		if(Extra3CPs == 1)
	        	{
	        	    SetTimerEx("EndRound",3000,false,"i",1);
				    GameTextForAll("~w~The round has ended.",3000,3);
				    RoundEnded = 1;
				    return 1;
	        	}
		        Extra3CPs = 1;
		        CPscleared = 0;
		        CPID = 0, CP_Activated = 0;
		        KillTimer(HTimer);
		        KillTimer(AirDTimer);
		        foreach(new i:Player) DisablePlayerCheckpoint(i);
		        KillTimer(RandomCPTimer);
				SetTimer("Extra3CPS", 3000, false);
				GameTextForAll("~y~Max ~r~infection ~y~level reached.",3000,3);
			}
		}
		infects = 0;
	}
	else TextDrawSetString(Infection,"infection____~r~~h~0%");
	if(CPscleared >= MAX_CP_CLEARED)
	{
	    if(RoundEnded == 0)
	    {
	        if(Extra3CPs == 1)
        	{
        	    SetTimerEx("EndRound",3000,false,"i",2);
			    GameTextForAll("~w~The round has ended.",3000,3);
			    RoundEnded = 1;
			    return 1;
        	}
	        Extra3CPs = 1;
	        CPscleared = 0;
	        CPID = 0, CP_Activated = 0;
	        KillTimer(HTimer);
	        KillTimer(AirDTimer);
	        foreach(new i:Player) DisablePlayerCheckpoint(i);
	        KillTimer(RandomCPTimer);
	    	SetTimer("Extra3CPS", 3000, false);
			GameTextForAll("~y~6 CPs Cleared Sucessfully.",3000,3);
		}
	}
	return 1;
}

function Extra3CPS()
{
	if(Extra3CPs == 1)
	{
	    foreach(new i:Player)
	    {
	        new infects, string2[45];
	        if(IsPlayerNPC(i)) continue;
		    if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		    if(PInfo[i][Firstspawn] == 1) continue;
		    if(PlayerState[i] == false) continue;
		    if(Team[i] == ZOMBIE) infects++;

			if(floatround(100.0 * floatdiv(infects, PlayersConnected)) >= 100)
			{
			    Team[i] = HUMAN;
			    SetPlayerColor(i, green);
			    new rand = random(162);
			    new rand2 = random(sizeof(RandomVS));
			    SetSpawnInfo(i, 0, HumansSkins[ rand ], RandomVS[rand2][0], RandomVS[rand2][1], RandomVS[rand2][2], RandomVS[rand2][3], 0, 0, 0, 0, 0, 0);
			    GameTextForAll("~r~3 ~w~EXTRA CPS !",5000,3);
			    MAX_CP_CLEARED = 3;

				SpawnPlayer(i);
				SetTimer("Random3Checkpoints", CPTIME, false);

		   		format(string2,sizeof string2,"~w~Checkpoints_cleared____~r~%i~w~/%i", CPscleared, MAX_CP_CLEARED);
		   		TextDrawSetString(CPSCleared,string2);
		   		TextDrawShowForAll(CPSCleared);
			}
			else
			{
				Team[i] = HUMAN;
				SetPlayerColor(i, green);
    			new rand = random(162);
			    new rand2 = random(sizeof(RandomVS));
			    SetSpawnInfo(i, 0, HumansSkins[ rand ], RandomVS[rand2][0], RandomVS[rand2][1], RandomVS[rand2][2], RandomVS[rand2][3], 0, 0, 0, 0, 0, 0);
		        GameTextForAll("~r~3 ~w~EXTRA CPS !",5000,3);
		        MAX_CP_CLEARED = 3;

				SpawnPlayer(i);
				SetTimer("Random3Checkpoints", CPTIME, false);

		   		format(string2,sizeof string2,"~w~Checkpoints_cleared____~r~%i~w~/%i", CPscleared, MAX_CP_CLEARED);
		   		TextDrawSetString(CPSCleared,string2);
		   		TextDrawShowForAll(CPSCleared);
			}
	    }
	}
	return 1;
}

function Random3Checkpoints()
{
	new rand = random(3);
	CPID = rand;
	if(RoundEnded == 1) return 0;
	if(rand == 0)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i, 2319.171386, 27.906017, 26.484375, 20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Palomino Creek Center");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 1;
		}
	}
	if(rand == 1)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i,1558.099975, 20.362739, 24.164062,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Red Country!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 2;
		}
	}
	if(rand == 2)
	{
		for(new i; i < MAX_PLAYERS;i++)
		{
			if(!IsPlayerConnected(i)) continue;
			if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
			SetPlayerCheckpoint(i,1944.628417, 232.126190, 30.467897,20.0);
		    SendClientMessage(i,white,"** "cred"Radio interferance...");
		    SendClientMessage(i,white,"» Announcer: "cblue"This is the Emergency Broadcast system THIS IS NOT A TEST!!");
		    SendClientMessage(i,white,"» Announcer: "cblue"If any survivors can hear me, head over to Red Country East!");
		    SendClientMessage(i,white,"» Announcer: "cblue"To get Health, Ammo, XP, Safety");
		    SendClientMessage(i,white,"** "cred"No battery left...");
		    CP_Activated = 3;
		}
	}
	SetTimer("CheckCP",1000,false);
	return 1;
}

function EndRound(win)
{
 	new number,there,idk,idd,idi,maxk,maxd,maxi,string[160];
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
	    if(PInfo[i][KillsRound] > maxk) idk = i, maxk = PInfo[i][KillsRound];
	    if(PInfo[i][DeathsRound] > maxd) idd = i, maxd = PInfo[i][DeathsRound];
	    if(PInfo[i][InfectsRound] > maxi) idi = i, maxi = PInfo[i][InfectsRound];
	    if(number >= 30)
	    {
	        SetPlayerPos(i,RandomEnd[random(sizeof(RandomEnd))][0],EndPos[random(sizeof(RandomEnd))][1],EndPos[random(sizeof(RandomEnd))][2]);
            SetPlayerFacingAngle(i,352.1313);
		}
        for(new j; j < MAX_PLAYERS;j++)
		{
			if(IsPlayerInRangeOfPoint(j,0.1,EndPos[number][0],EndPos[number][1],EndPos[number][2]))
				there = 1;
		}
		if(there == 0) SetPlayerPos(i,EndPos[number][0],EndPos[number][1],EndPos[number][2]+1),number++,there = 0;

		TogglePlayerControllable(i,0);
		Streamer_UpdateEx(i, 1765.365478, -1955.114257, 13.546875);
		InterpolateCameraPos(i, 1765.365478, -1955.114257, 13.546875, 1842.036499, -1955.057739, 29.847051, 6000);
		InterpolateCameraLookAt(i, 1768.667968, -1951.364868, 13.358379, 1840.537109, -1950.660400, 27.998983, 6000);

		PlayAudioStreamForPlayer(i, "http://k003.kiwi6.com/hotlink/ayll1qammj/Marilyn_Manson_-_Resident_Evil_movie_soundtrack_2008_mp3cut.net_.mp3", 45);

		PlayerTextDrawHide(i, XPBox[i][0]);
		PlayerTextDrawHide(i, XPBox[i][1]);
		PlayerTextDrawHide(i, StatsBoxDraw[i]);
	}

	TextDrawHideForAll(Infection);
	TextDrawHideForAll(CPSCleared);
	TextDrawHideForAll(RoundStats);
	TextDrawHideForAll(RadioBox);
	TextDrawHideForAll(StatsBox[0]);
	TextDrawHideForAll(StatsBox[1]);
	TextDrawHideForAll(CP_Name);

	Extra3CPs = 0;
	number = 0;
	format(string,sizeof string,"~g~~h~Most Kills: ~w~%s ~n~~g~~h~Most Deaths: ~w~%s ~n~~g~~h~Most Infects: ~w~%s",
	    GetPName(idk),GetPName(idd),GetPName(idi));
	TextDrawSetString(RoundStats,string);
	TextDrawShowForAll(RoundStats);

	if(win == 1) GameTextForAll("~r~~h~100% of zombie infection!",6000,3);
	else GameTextForAll("~g~~h~Humans have cleared all the ~n~~r~~h~checkpoints~g~~h~!",6000,3);

	for(new i; i < MAX_PLAYERS;i++) {
	    new playerid; playerid = i;
	    SetTimerEx("EndRound2", 6000, false, "i", playerid);
	}
	return 1;
}

function EndRound2(playerid)
{
    Streamer_UpdateEx(playerid, 1842.036499, -1955.057739, 29.847051);
    InterpolateCameraPos(playerid, 1842.036499, -1955.057739, 29.847051, 1822.736450, -1731.843627, 19.665786, 6000);
	InterpolateCameraLookAt(playerid, 1840.537109, -1950.660400, 27.998983, 1817.764648, -1731.348754, 19.475986, 6000);
	GameTextForAll("~b~~h~Thanks for playing!",6000,3);
    SetTimer("EndRound3", 6000, false);
	return 1;
}

function EndRound3(playerid)
{
    Streamer_UpdateEx(playerid, 1822.736450, -1731.843627, 19.665786);
    InterpolateCameraPos(playerid, 1822.736450, -1731.843627, 19.665786, 1516.314697, -1743.069702, 37.685371, 6000);
	InterpolateCameraLookAt(playerid, 1817.764648, -1731.348754, 19.475986, 1517.327636, -1738.470825, 36.004932, 6000);
    GameTextForAll("~w~eternal-~b~~h~~h~G~w~ames~b~~h~~h~.~w~net", 6000, 3);
    SetTimer("EndRoundFinal", 6000, false);
	return 1;
}

function EndRoundFinal()
{
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
		GameTextForPlayer(i,"~y~Please wait, you are being ~n~~g~~h~reconnected!",6000,3);
	}
	SendRconCommand("gmx");
	return 1;
}

function AllowedToStomp(playerid)
{
	if(PInfo[playerid][CanStomp] == 0)
	{
		SendClientMessage(playerid,red,"» You feel rested to send a mini earthquake (stomp ready)");
		PInfo[playerid][CanStomp] = 1;
	}
	return 1;
}

function PopAgain(playerid)
{
	if(PInfo[playerid][CanPop] == 0)
	{
		SendClientMessage(playerid,red,"» You feel rested to pop vehicle tires. (popping tires ready)");
		PInfo[playerid][CanPop] = 1;
	}
	return 1;
}

function Float:GetDistanceBetweenPoints(Float:rx1,Float:ry1,Float:rz1,Float:rx2,Float:ry2,Float:rz2)
{
    return floatadd(floatadd(floatsqroot(floatpower(floatsub(rx1,rx2),2)),floatsqroot(floatpower(floatsub(ry1,ry2),2))),floatsqroot(floatpower(floatsub(rz1,rz2),2)));
}

stock GetClosestPlayer(playerid,Float:limit)
{
    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(playerid,x1,y1,z1);
    new Float:Range = 999.9;
    new id = -1;
    for(new i; i < MAX_PLAYERS;i++)
    {
        if(!IsPlayerConnected(i) || IsPlayerNPC(i)) continue;
        if(playerid != i)
        {
            GetPlayerPos(i,x2,y2,z2);
            new Float:Dist = GetDistanceBetweenPoints(x1,y1,z1,x2,y2,z2);
            if(floatcmp(Range,Dist) == 1 && floatcmp(limit,Range) == 1)
            {
                Range = Dist;
                id = i;
            }
        }
    }
    return id;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
    for(new i = 0; i < 13; i++)
    {
        if(pickupid == PMeat[i])
        {
            if(Team[playerid] == 2)
            {
                new Float:hp;
				GetPlayerHealth(playerid, hp);
                if(hp >= 75) return 1;
                DestroyDynamicPickup(PMeat[i]);
	            SetPlayerHealth(playerid, 100);
			}
            return true;
        }
    }

    if(pickupid == Pumpkin)
	{
		new
			string[256],
			randxp = 10 + random(25),
			Hour, Minute, Second;

		Winner = 1;
		PumpkinOn = 0;
		SendFMessageToAll(COLOR_MAUVE, "» Pumpkin was found by %s. His wish him congratulations!", GetPName(playerid));
		gettime(Hour, Minute, Second);
		SendFMessageToAll(COLOR_MAUVE, "» A new pumpkin will be hidden in %d minutes.", Minutes-Minute+10);
		SendFMessage(playerid, white, "» {2C8522}You won the sum of %d XP !", randxp);

 		if(PInfo[playerid][Premium] == 0){ PInfo[playerid][XP] += randxp; PInfo[playerid][CurrentXP] = randxp; }
	 	else if(PInfo[playerid][Premium] == 1){ PInfo[playerid][XP] += randxp; PInfo[playerid][CurrentXP] = randxp; }
		else if(PInfo[playerid][Premium] == 2){ PInfo[playerid][XP] += randxp; PInfo[playerid][CurrentXP] = randxp; }

        CheckRankup(playerid);

		format(string,sizeof string,"+%i XP",PInfo[playerid][CurrentXP]);
		TextDrawSetString(GainXPTD[playerid],string);
		PInfo[playerid][ShowingXP] = 1;
		SetTimerEx("ShowXP1", 300, 0, "i", playerid);
	    TextDrawShowForPlayer(playerid, GainXPTD[playerid]);
	    PlaySound(playerid, 1083);

	    DestroyDynamicPickup(Pumpkin);
	}
	return 1;
}

function Flashbang(playerid)
{
	TextDrawShowForPlayer(playerid,Effect[0]);
	SetTimerEx("Flashbang2", 3500, false, "i", playerid);
	new Float:X,Float:Y,Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	PlayerPlaySound(playerid,1159,X,Y,Z);
	PlayerPlaySound(playerid,1159,X,Y,Z);
	PlayerPlaySound(playerid,1159,X,Y,Z);
	PlayerPlaySound(playerid,1159,X,Y,Z);
	PlayerPlaySound(playerid,1159,X,Y,Z);
	PlayerPlaySound(playerid,1159,X,Y,Z);
	PlayerPlaySound(playerid,1159,X,Y,Z);
	PlayerPlaySound(playerid,1159,X,Y,Z);
	return 1;
}

function Flashbang2(playerid)
{
	TextDrawHideForPlayer(playerid,Effect[0]);
	TextDrawShowForPlayer(playerid,Effect[1]);
	SetTimerEx("Flashbang3", 1000, false, "i", playerid);
	return 1;
}
function Flashbang3(playerid)
{
	TextDrawHideForPlayer(playerid,Effect[1]);
	TextDrawShowForPlayer(playerid,Effect[2]);
	SetTimerEx("Flashbang4", 600, false, "i", playerid);
	return 1;
}

function Flashbang4(playerid)
{
	TextDrawHideForPlayer(playerid,Effect[2]);
	TextDrawShowForPlayer(playerid,Effect[3]);
	SetTimerEx("Flashbang5", 600, false, "i", playerid);
	return 1;
}

function Flashbang5(playerid)
{
	TextDrawHideForPlayer(playerid,Effect[3]);
	TextDrawShowForPlayer(playerid,Effect[4]);
	SetTimerEx("Flashbang6", 600, false, "i", playerid);
	return 1;
}

function Flashbang6(playerid)
{
	TextDrawHideForPlayer(playerid,Effect[4]);
	TextDrawShowForPlayer(playerid,Effect[5]);
	SetTimerEx("Flashbang7", 600, false, "i", playerid);
	return 1;
}

function Flashbang7(playerid)
{
	TextDrawHideForPlayer(playerid,Effect[6]);
	TextDrawShowForPlayer(playerid,Effect[7]);
	SetTimerEx("Flashbang9", 600, false, "i", playerid);
	return 1;
}

/*function Flashbang8(playerid)
{
	TextDrawHideForPlayer(playerid,Effect[7]);
	TextDrawShowForPlayer(playerid,Effect[8]);
	SetTimerEx("Flashbang9", 600, false, "i", playerid);
	return 1;
}*/

function Flashbang9(playerid)
{
	for(new i; i < 8; i++)
		TextDrawHideForPlayer(playerid,Effect[i]);
	return 1;
}

stock GetClosestVehicle(playerid,Float:range)
{
    new car, Float:ang;
    car = -1;
    ang = 9999.9999;

    for(new i = 0; i < MAX_PLAYERS; i++)
    for(new v = 0; v < MAX_VEHICLES; v++)
    {
        #define INVALID_ID (0xFFFF)
        if(!IsPlayerConnected(i) && v == INVALID_ID) continue;
        if(!IsPlayerInVehicle(i, v))
        {
            new Float:X, Float:Y, Float:Z;
            GetVehiclePos(v, X, Y, Z);

            if(ang > GetPlayerDistanceFromPoint(playerid, X, Y, Z))
            {
                if(IsPlayerInRangeOfPoint(i,range,X,Y,Z))
                {
                	ang = GetPlayerDistanceFromPoint(playerid, X, Y, Z);
                	car = v;
               	}
            }
        }
    }
    return car;
}

stock GivePlayerXP(playerid)
{
	if(Team[playerid] == ZOMBIE)
	{
     	if(PInfo[playerid][ShowingXP] == 0)
	    {
			new string[7];
		 	if(PInfo[playerid][Premium] == 0){ PInfo[playerid][XP] += 16; PInfo[playerid][CurrentXP] = 16; }
		 	else if(PInfo[playerid][Premium] == 1){ PInfo[playerid][XP] += 24; PInfo[playerid][CurrentXP] = 24; }
			else if(PInfo[playerid][Premium] == 2){ PInfo[playerid][XP] += 32; PInfo[playerid][CurrentXP] = 32; }

			if(PInfo[playerid][ClanID] != 0)
			{
				format(DB_Query, sizeof(DB_Query), "UPDATE CLANS SET XP = XP + %d WHERE ID = '%d'", PInfo[playerid][CurrentXP], PInfo[playerid][ClanID]);
				db_query(Database, DB_Query);
				CInfo[PInfo[playerid][ClanID]][C_XP]+=PInfo[playerid][CurrentXP];
			}

			PInfo[playerid][InfectsRound]++;
			format(string,sizeof string,"+%i XP",PInfo[playerid][CurrentXP]);
			TextDrawSetString(GainXPTD[playerid],string);
			PInfo[playerid][ShowingXP] = 1;
			SetTimerEx("ShowXP1",300,0,"d",playerid);
		    TextDrawShowForPlayer(playerid,GainXPTD[playerid]);
		    PlaySound(playerid,1083);
		}
		else
		{
		    new string[7];
			if(PInfo[playerid][ClanID] != 0)
			{
				format(DB_Query, sizeof(DB_Query), "UPDATE CLANS SET XP = XP + %d WHERE ID = '%d'", PInfo[playerid][CurrentXP], PInfo[playerid][ClanID]);
				db_query(Database, DB_Query);
				CInfo[PInfo[playerid][ClanID]][C_XP]+=PInfo[playerid][CurrentXP];
			}

			PInfo[playerid][InfectsRound]++;
			format(string,sizeof string,"+%i XP",PInfo[playerid][CurrentXP]);
		    TextDrawSetString(GainXPTD[playerid],string);
		    PlaySound(playerid,1083);
		}
	}
	else
	{
	    if(PInfo[playerid][ShowingXP] == 0)
  		{
			new string[7];
	 		if(PInfo[playerid][Premium] == 0){ PInfo[playerid][XP] += 10; PInfo[playerid][CurrentXP] = 10; }
		 	else if(PInfo[playerid][Premium] == 1){ PInfo[playerid][XP] += 20; PInfo[playerid][CurrentXP] = 20; }
			else if(PInfo[playerid][Premium] == 2){ PInfo[playerid][XP] += 30; PInfo[playerid][CurrentXP] = 30; }

			if(PInfo[playerid][ClanID] != 0)
			{
				format(DB_Query, sizeof(DB_Query), "UPDATE CLANS SET XP = XP + %d WHERE ID = '%d'", PInfo[playerid][CurrentXP], PInfo[playerid][ClanID]);
				db_query(Database, DB_Query);
				CInfo[PInfo[playerid][ClanID]][C_XP]+=PInfo[playerid][CurrentXP];
			}

			PInfo[playerid][InfectsRound]++;
			format(string,sizeof string,"+%i XP",PInfo[playerid][CurrentXP]);
			TextDrawSetString(GainXPTD[playerid],string);
			PInfo[playerid][ShowingXP] = 1;
		    SetTimerEx("ShowXP1",300,0,"d",playerid);
		    TextDrawShowForPlayer(playerid,GainXPTD[playerid]);
		    PlaySound(playerid,1083);
		}
		else
		{
	        new string[7];
	 		if(PInfo[playerid][Premium] == 0){ PInfo[playerid][XP] += 10; PInfo[playerid][CurrentXP] = 10; }
		 	else if(PInfo[playerid][Premium] == 1){ PInfo[playerid][XP] += 20; PInfo[playerid][CurrentXP] = 20; }
			else if(PInfo[playerid][Premium] == 2){ PInfo[playerid][XP] += 30; PInfo[playerid][CurrentXP] = 30; }

			if(PInfo[playerid][ClanID] != 0)
			{
				format(DB_Query, sizeof(DB_Query), "UPDATE CLANS SET XP = XP + %d WHERE ID = '%d'", PInfo[playerid][CurrentXP], PInfo[playerid][ClanID]);
				db_query(Database, DB_Query);
				CInfo[PInfo[playerid][ClanID]][C_XP]+=PInfo[playerid][CurrentXP];
			}

			PInfo[playerid][InfectsRound]++;
	        format(string,sizeof string,"+%i XP",PInfo[playerid][CurrentXP]);
	        TextDrawSetString(GainXPTD[playerid],string);
	        PlaySound(playerid,1083);

		}
	}
	return 1;
}

stock DamagePlayer(playerid,i)
{
	new Float:Health;
    GetPlayerHealth(i,Health);
    if(Health >= 1.0 && Health <= 10.0)
		SetPlayerHealth(i,5.0);
    if(PInfo[playerid][ZPerk] == 18)
	{
	    if(PInfo[i][SPerk] != 5)
		{
		    if(Health <= 10.0 && Health > 0.0)
		    	MakeProperDamage(i);
			else
			    SetPlayerHealth(i,Health-7.0);
		}
		else
		{
		    if(Health <= 10.0 && Health > 0.0)
		    	MakeProperDamage(i);
			else
			    SetPlayerHealth(i,Health-9.0);
		}
		GetPlayerHealth(playerid,Health);
		if(Health >= 100.0) SetPlayerHealth(playerid,100.0);
		else SetPlayerHealth(playerid,Health+6.0);
	}
	else if(PInfo[i][SPerk] == 5)
	{
		GetPlayerHealth(i,Health);
		if(PInfo[playerid][ZPerk] == 1)
		{
			if(Health <= 10.0 && Health > 0.0)
		    	MakeProperDamage(i);
			else
			    SetPlayerHealth(i,Health-7.0);
		}
		else SetPlayerHealth(i,Health-4.0);
	}
    else
	{
		GetPlayerHealth(i,Health);
    	if(PInfo[playerid][ZPerk] == 1)
		{
		    if(Health <= 10.0 && Health > 0.0)
		    	MakeProperDamage(i);
			else
      			SetPlayerHealth(i,Health-10.0);
		}
		else if(PInfo[playerid][ZPerk] != 18)
		{
		    if(Health <= 10.0 && Health > 0.0)
		    	MakeProperDamage(i);
			else
   				SetPlayerHealth(i,Health-7.0);
		}
	}
 	GetPlayerHealth(i,Health);
	if(Health <= 5)
	{
		GetPlayerPos(i, ZPS[i][0], ZPS[i][1], ZPS[i][2]);
 		GetPlayerFacingAngle(i, ZPS[i][3]);
 		SetSpawnInfo(i, 0, ZombieSkins[random(sizeof(ZombieSkins))], ZPS[i][0], ZPS[i][1], ZPS[i][2], ZPS[i][3], 0, 0, 0, 0, 0, 0);

	    GivePlayerXP(playerid);
	    CheckRankup(playerid);

	    foreach(new j:Player)
	    {
	        if(Team[j] == HUMAN) continue;
		    if(IsPlayerInRangeOfPoint(j, 20.0, ZPS[i][0], ZPS[i][1], ZPS[i][2]))
		    {
		        if(j == playerid) continue;
		        if(IsSpecing[playerid] == 1) continue;

			 	if(PInfo[j][Premium] == 0){ PInfo[j][XP] += 8; PInfo[j][CurrentXP] = 8; }
			 	else if(PInfo[j][Premium] == 1){ PInfo[j][XP] += 16; PInfo[j][CurrentXP] = 16; }
				else if(PInfo[j][Premium] == 2){ PInfo[j][XP] += 24; PInfo[j][CurrentXP] = 24; }

		        PInfo[j][Assists]++;
		        CheckRankup(j);

				PInfo[j][InfectsRound]++;
				new string[7];
				format(string,sizeof string,"+%i XP",PInfo[j][CurrentXP]);
				TextDrawSetString(GainXPTD[j],string);
				PInfo[j][ShowingXP] = 1;
				SetTimerEx("ShowXP1", 300, 0, "i", j);
			    TextDrawShowForPlayer(j, GainXPTD[j]);
			    PlaySound(j, 1083);
		    }
		}
	    //InfectPlayer(i);

     	PInfo[i][Deaths]++;
		PInfo[i][JustInfected] = 1;
		PInfo[playerid][Infects]++;
		PInfo[i][Infected] = 0;
		PInfo[i][Dead] = 1;

		SpawnPlayer(i);

	    Team[i] = ZOMBIE;
	    GameTextForPlayer(i,"~r~~h~Infected!",4000,3);
	    if(PInfo[playerid][ClanID] != 0) CInfo[PInfo[playerid][ClanID]][C_INFECTS]++, SaveClanStats(PInfo[playerid][ClanID]);
	    SetPlayerColor(i, purple);
		PInfo[playerid][InfectsRound]++;
		PInfo[i][DeathsRound]++;

		SendFMessageToAll(0xA4A4A4FF, "** %s has been infected.", GetPName(i));

		new string[200];
		format(string,sizeof(string),"04*** %s has been infected.", GetPName(i));
		IRC_GroupSay(gGroupID, IRC_CHANNEL, string);

	    new string2[45];
    	if(PInfo[i][Premium] == 1) {
			format(string2,sizeof string2,""cgold"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]); }
		else if(PInfo[i][Premium] == 2) {
		    format(string2,sizeof string2,""cplat"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]); }
		else {
		    format(string2,sizeof string2,""cpurple"Rank: %i | XP: %i/%i",PInfo[i][Rank],PInfo[i][XP],PInfo[i][XPToRankUp]); }

		Update3DTextLabelText(PInfo[i][Ranklabel],0x00E800FF,string2);
	}
	return 1;
}

stock MakeProperDamage(playerid)
{
	new Float:Health;
	GetPlayerHealth(playerid,Health);
	if(Health <= 10.0 && Health >= 5.0)
	    SetPlayerHealth(playerid,4.0);
	else if(Health <= 5.0 && Health > 0.0)
	    SetPlayerHealth(playerid,1.0);
	return 1;
}

function ResetRunVar(playerid,var)
{
	if(var == 1)
	{
	    if(Team[playerid] == HUMAN)
	    {
     		if(!IsPlayerInAnyVehicle(playerid)) ApplyAnimation(playerid,"PED","run_stopr",10,1,1,1,0,1,1);
     		PInfo[playerid][RunTimer] = SetTimerEx("ResetRunVar",120000,false,"ii",playerid,2);
     		PInfo[playerid][CanRun] = 0;
	    }
	}
	if(var == 2)
	{
	    if(Team[playerid] == HUMAN)
	    {
	        SendClientMessage(playerid,white,"* "cred"You feel rested enough to run faster (more stamina ready)");
	        PInfo[playerid][CanRun] = 1;
	        PInfo[playerid][RunTimerActivated] = 0;
	    }
	}
	return 1;
}

function BanPlayer(playerid)
	return BanEx(playerid,"Ban evading");

function ResetDigVar(playerid)
	return PInfo[playerid][CanDig] = 1, SendClientMessage(playerid,white, "* "cred"You have enough energy to dig again. (digger ready)");

stock GetIP(playerid)
{
	new ip[16];
	GetPlayerIp(playerid,ip,16);
	return ip;
}

/*function SetPlayerHealthRank(playerid)
{
	if(PInfo[playerid][Rank] == 1) SetPlayerHealth(playerid,10);
	if(PInfo[playerid][Rank] == 2) SetPlayerHealth(playerid,15);
	if(PInfo[playerid][Rank] == 3) SetPlayerHealth(playerid,20);
	if(PInfo[playerid][Rank] == 4) SetPlayerHealth(playerid,25);
	if(PInfo[playerid][Rank] == 5) SetPlayerHealth(playerid,30);
	if(PInfo[playerid][Rank] == 6) SetPlayerHealth(playerid,35);
	if(PInfo[playerid][Rank] == 7) SetPlayerHealth(playerid,40);
	if(PInfo[playerid][Rank] == 8) SetPlayerHealth(playerid,50);
	if(PInfo[playerid][Rank] == 9) SetPlayerHealth(playerid,60);
	if(PInfo[playerid][Rank] == 10) SetPlayerHealth(playerid,70);
	if(PInfo[playerid][Rank] == 11) SetPlayerHealth(playerid,80);
	if(PInfo[playerid][Rank] == 12) SetPlayerHealth(playerid,85);
	if(PInfo[playerid][Rank] == 13) SetPlayerHealth(playerid,90);
	if(PInfo[playerid][Rank] == 14) SetPlayerHealth(playerid,95);
    if(PInfo[playerid][Rank] >= 15) SetPlayerHealth(playerid,100);
	return 1;
}*/

stock IsPlayerInRangeOfObject(playerid, Float:range, objectid)
{
    new Float:pos[3];
    GetObjectPos(objectid, pos[0], pos[1], pos[2]);
    return IsPlayerInRangeOfPoint(playerid, range, pos[0], pos[1], pos[2]);
}

function ExplodeBetty(playerid,id)
{
	new Float:x,Float:y,Float:z;
	if(id == 1)
	{
		GetObjectPos(PInfo[playerid][BettyObj1],x,y,z);
		CreateExplosion(x,y,z,2,9);
		DestroyObject(PInfo[playerid][BettyObj1]);
		PInfo[playerid][BettyActive1] = 0;
	}
	if(id == 2)
	{
		GetObjectPos(PInfo[playerid][BettyObj2],x,y,z);
		CreateExplosion(x,y,z,2,9);
		DestroyObject(PInfo[playerid][BettyObj2]);
		PInfo[playerid][BettyActive2] = 0;
	}
	if(id == 3)
	{
		GetObjectPos(PInfo[playerid][BettyObj3],x,y,z);
		CreateExplosion(x,y,z,2,9);
		DestroyObject(PInfo[playerid][BettyObj3]);
		PInfo[playerid][BettyActive3] = 0;
	}
	return 1;
}

function ActivateBetty(playerid,id)
{
    if(id == 1)
	{
	 	PInfo[playerid][BettyActive1] = 1;
	}
	if(id == 2)
	{
		PInfo[playerid][BettyActive2] = 1;
	}
	if(id == 3)
	{
		PInfo[playerid][BettyActive3] = 1;
	}
	return 1;
}


/*function PutGlassesOn(playerid)
{
    new skin, id, slot, glasseid;
	skin = GetPlayerSkin(playerid);
	id = randomEx(1,34);
	PInfo[playerid][oslotglasses] = 6;
	RemovePlayerAttachedObject(playerid,PInfo[playerid][oslotglasses]);
	if(id > 30) goto PutPoliceGlasses;
	else
	{
	    id--;
	    glasseid =  CommonRed + id;
	    if(PInfo[playerid][oslotglasses] != -1) RemovePlayerAttachedObject(playerid,PInfo[playerid][oslotglasses]);
		SetPlayerAttachedObject(playerid, slot, glasseid, 2, SkinOffSetGlasses[skin][0], SkinOffSetGlasses[skin][1], SkinOffSetGlasses[skin][2], SkinOffSetGlasses[skin][3], SkinOffSetGlasses[skin][4], SkinOffSetGlasses[skin][5], SkinOffSetGlasses[skin][6], SkinOffSetGlasses[skin][6], SkinOffSetGlasses[skin][6]);
		return 1;
	}
	PutPoliceGlasses:
	glasseid = CopGlassesBlack + (id - 31);
	if(PInfo[playerid][oslotglasses] != -1) RemovePlayerAttachedObject(playerid,PInfo[playerid][oslotglasses]);
	SetPlayerAttachedObject(playerid, slot, glasseid, 2, SkinOffSetGlasses[skin][0], floatadd(SkinOffSetGlasses[skin][1], 0.004500), SkinOffSetGlasses[skin][2], SkinOffSetGlasses[skin][3], SkinOffSetGlasses[skin][4], SkinOffSetGlasses[skin][5], SkinOffSetGlasses[skin][6], SkinOffSetGlasses[skin][6], SkinOffSetGlasses[skin][6]);
	return 1;
}

function PutHatOn(playerid)
{
    new skin, id = randomEx(1,12), beret, count;
 	skin = (GetPlayerSkin(playerid) - 1);
 	PInfo[playerid][oslothat] = 5;
 	RemovePlayerAttachedObject(playerid,PInfo[playerid][oslotglasses]);
	switch(id)
	{
	    case 1:     beret = 18926;
	    case 2..10: beret = 18926 + id;
	    case 11:    beret = 19099;
	}
	do
	{
		if(skin == invalidskins[count]) return 1; // SendClientMessage(playerid, red, "» "cyellow"Your skin does not support a hat.");
		count++;
	}
	while(count < sizeof invalidskins);
	if(skin < 0) skin = 0;
	SetPlayerAttachedObject(playerid, PInfo[playerid][oslothat], beret, 2, SkinOffSetHat[skin][0], SkinOffSetHat[skin][1], SkinOffSetHat[skin][2], SkinOffSetHat[skin][3], SkinOffSetHat[skin][4], SkinOffSetHat[skin][5]);
	return 1;
}*/

stock IsPlatVehicle(vehicleid)
{
	if(GetVehicleModel(vehicleid) == 409) return 1;
	if(GetVehicleModel(vehicleid) == 434) return 1;
	if(GetVehicleModel(vehicleid) == 541) return 1;
	if(GetVehicleModel(vehicleid) == 571) return 1;
	if(GetVehicleModel(vehicleid) == 444) return 1;
	return 0;
}

stock InfectPlayer(playerid)
{
    SetPlayerHealth(playerid, 100);
	PInfo[playerid][JustInfected] = 1;
	SpawnPlayer(playerid);
	PInfo[playerid][Dead] = 1;
    Team[playerid] = ZOMBIE;
    GameTextForPlayer(playerid,"~r~~h~Infected!",4000,3);
    SetPlayerColor(playerid,purple);
	PInfo[playerid][DeathsRound]++;
	return 1;
}

function ServerSettings()
{
	new string[150];
	format(string,sizeof(string),"Zombies - CP: %d/%d", CPscleared, MAX_CP_CLEARED);
    SetGameModeText(string);

	if(ServerN == 0)
	{
		SendRconCommand("hostname [eG] Zombie Apocalyptic Outbreak 2.0");
        SetTimer("ServerSettings", 2500,0);
		ServerN = 1;
	}
	else if(ServerN == 1)
	{
		SendRconCommand("hostname eternal-Games.net ® Zombie Mode - Double XP!");
        SetTimer("ServerSettings", 1500,0);
		ServerN = 0;
	}
	return 1;
}


ServerPickUps()
{
    // PickUps
	PMeat[0] = CreateDynamicPickup(1318, 8, 51.994808, 1509.515014, 12.855980, -1);
	PMeat[1] = CreateDynamicPickup(1318, 8, 52.158638, 1520.553100, 12.910239, -1);
	PMeat[2] = CreateDynamicPickup(1318, 8, 52.783847, 1515.090209, 13.054675, -1);
	PMeat[3] = CreateDynamicPickup(1318, 8, 55.119438, 1511.395996, 12.880279, -1);
	PMeat[4] = CreateDynamicPickup(1318, 8, 57.538402, 1519.051025, 12.750000, -1);
	PMeat[5] = CreateDynamicPickup(1318, 8, 21.242126, 1500.858398, 12.750000, -1);
	PMeat[6] = CreateDynamicPickup(1318, 8, 25.972902, 1507.447021, 12.894519, -1);
	PMeat[7] = CreateDynamicPickup(1318, 8, 19.549327, 1509.684326, 12.756023, -1);
	PMeat[8] = CreateDynamicPickup(1318, 8, 20.148994, 1538.024902, 12.880279, -1);
	PMeat[9] = CreateDynamicPickup(1318, 8, 12.162050, 1535.587646, 13.054675, -1);
	PMeat[10] = CreateDynamicPickup(1318, 8, 39.898731, 1547.619873, 12.750000, -1);
	PMeat[11] = CreateDynamicPickup(1318, 8, 50.752544, 1549.951660, 12.855980, -1);
	PMeat[12] = CreateDynamicPickup(1318, 8, 49.708339, 1542.966796, 12.880279, -1);

	ZTPS[0] = CreateDynamicPickup(1318, 1, 63.665149, 1539.632690, 12.800000, -1);
	ZTPS[1] = CreateDynamicPickup(1318, 1, 27.856601, 1571.499267, 12.800000, -1);
	ZTPS[2] = CreateDynamicPickup(1318, 1, 6.460189, 1574.291381, 12.800000, -1);
	ZTPS[3] = CreateDynamicPickup(1318, 1, -31.724969, 1502.337280, 12.800000, -1);
	ZTPS[4] = CreateDynamicPickup(1318, 1, 34.202831, 1486.785034, 12.800000, -1);

 	TPZone[0] = CreateDynamicPickup(1318, 1, 2606.136230, -1463.581054, 19.009654, -1); // Groove
 	TPZone[1] = CreateDynamicPickup(1318, 1, 1694.141113, -1971.765380, 8.824961, -1); // Unity
 	TPZone[2] = CreateDynamicPickup(1318, 1, 1547.274780, -1636.830566, 6.218750, -1); // LSPD
 	TPZone[3] = CreateDynamicPickup(1318, 1, 1294.354125, -1249.394653, 13.600000, -1); // Hospital
 	TPZone[4] = CreateDynamicPickup(1318, 1, 1908.839355, -1318.581298, 14.199999, -1); // Glen
 	TPZone[5] = CreateDynamicPickup(1318, 1, 831.413146, -1390.246582, -0.553125, -1); // Market
 	TPZone[6] = CreateDynamicPickup(1318, 1, 998.767272, -897.245483, 42.300121, -1); // Vinewood
 	TPZone[7] = CreateDynamicPickup(1318, 1, 2795.812744, -1176.926879, 28.915470, -1); // Playa Costera
 	TPZone[8] = CreateDynamicPickup(1318, 1, 1618.350830, -993.629333, 24.067668, -1); // Mulhegan
 	TPZone[9] = CreateDynamicPickup(1318, 1, 358.485534, -1755.051025, 5.524650, -1); // Beach

 	for(new p; p<sizeof pZPos; p++)
	{
	    new string[60];
	    format(string, sizeof(string), ""cwhite"Press "cred"C "cwhite"to use the TP");
 		CreateDynamic3DTextLabel(string, 0xFFFFFFFF, pZPos[p][0], pZPos[p][1], pZPos[p][2], 15.0);
	}
	return 1;
}

function RandomMessage()
{
	if(MRR == 0) {
		SendClientMessageToAll(0xD89200FF,"* SERVER ANNOUNCEMENT *");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}You can use {72CF86}/help {77BD30}if you're new in the server.");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Puedes utilizar {72CF86}/ayuda {77BD30}para ver las guнas del servidor.");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Use o comando {72CF86}/ajuda {77BD30}se vocк for novo no servidor.");
		MRR ++;
		return 1;
	}
	else if(MRR == 1) {
		SendClientMessageToAll(0xD89200FF,"* SERVER ANNOUNCEMENT *");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Visit our website at {72CF86}eternal-games.net");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Visita nuestra pбgina {72CF86}eternal-games.net");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Visite o nosso website {72CF86}eternal-games.net");
		MRR ++;
		return 1;
	}
	else if(MRR == 2) {
		SendClientMessageToAll(0xD89200FF,"* SERVER ANNOUNCEMENT *");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Right mouse button (RMB) to bite as zombie | Space bar in car.");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Click derecho (RMB) para morder siendo zombie | Barra Espaciadora para morder en coche.");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Utilize o botгo de mirar do seu mouse (RMB) para morder um humano | Tecla 'espaзo' para morder um humano dentro de um carro.");
		MRR ++;
		return 1;
	}
	else if(MRR == 3) {
		SendClientMessageToAll(0xD89200FF,"* SERVER ANNOUNCEMENT *");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Bunnyhop is NOT allowed and you can get punished.");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}No estб permitido dar saltos continuados para ganar velocidad. (BH)");
		SendClientMessageToAll(0xD89200FF,"* {77BD30}Bunnyhop (pular para ganhar velocidade) nгo й permitido neste servidor!");
		MRR = 0;
		return 1;
	}
	else return 1;
}

stock AddPlayerClasses()
{
	AddPlayerClass(162,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 0
	AddPlayerClass(78,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 1 //78
	AddPlayerClass(79,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 2 //79
	AddPlayerClass(134,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 3//134
	AddPlayerClass(135,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 4 //135
	AddPlayerClass(137,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 5//137
	AddPlayerClass(160,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 6//160
	AddPlayerClass(212,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 7//212
	AddPlayerClass(230,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Zombie 8 Hunter//230
	AddPlayerClass(63,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// ZombieMujer 9//63
	AddPlayerClass(75,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// ZombieMujer 10//75
	AddPlayerClass(77,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// ZombieMujer 11
    AddPlayerClass(7,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 12
    AddPlayerClass(1,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 13
	AddPlayerClass(2,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 14
	AddPlayerClass(9,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 15
	AddPlayerClass(10,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 16
	AddPlayerClass(14,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 17
	AddPlayerClass(15,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 18
	AddPlayerClass(13,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 19
	AddPlayerClass(16,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 20
	AddPlayerClass(17,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 21
	AddPlayerClass(18,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 22
	AddPlayerClass(19,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 23
	AddPlayerClass(20,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 24
	AddPlayerClass(21,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 25
	AddPlayerClass(22,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 26
	AddPlayerClass(23,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 27
	AddPlayerClass(24,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 28
	AddPlayerClass(25,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 29
	AddPlayerClass(26,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 30
	AddPlayerClass(27,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 31
	AddPlayerClass(28,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 32
	AddPlayerClass(29,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 33
	AddPlayerClass(30,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 34
	AddPlayerClass(31,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 35
	AddPlayerClass(32,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 36
	AddPlayerClass(33,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 37
	AddPlayerClass(34,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 38
	AddPlayerClass(35,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 39
	AddPlayerClass(36,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 40
	AddPlayerClass(37,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 41
	AddPlayerClass(38,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 42
	AddPlayerClass(39,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 43
	AddPlayerClass(40,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 44
	AddPlayerClass(41,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 45
	AddPlayerClass(43,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 46
	AddPlayerClass(44,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 47
	AddPlayerClass(45,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 48
	AddPlayerClass(46,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 49
	AddPlayerClass(47,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 50
    AddPlayerClass(48,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 51
    AddPlayerClass(49,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 52
    AddPlayerClass(50,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 53
    AddPlayerClass(51,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 54
	AddPlayerClass(52,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 55
	AddPlayerClass(54,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 56
	AddPlayerClass(55,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 57
	AddPlayerClass(56,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 58
	AddPlayerClass(57,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 59
	AddPlayerClass(58,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 60
	AddPlayerClass(59,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 61
	AddPlayerClass(61,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 62
	AddPlayerClass(62,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 63
	AddPlayerClass(30,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 64
	AddPlayerClass(64,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 65
	AddPlayerClass(68,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 66
	AddPlayerClass(69,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 67
	AddPlayerClass(66,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 68
	AddPlayerClass(70,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 69
	AddPlayerClass(72,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 70
	AddPlayerClass(73,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 71
	AddPlayerClass(120,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 72
	AddPlayerClass(76,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 73
	AddPlayerClass(80,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 74
	AddPlayerClass(81,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 75
	AddPlayerClass(82,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 76
	AddPlayerClass(83,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 77
	AddPlayerClass(84,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 78
	AddPlayerClass(85,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 79
	AddPlayerClass(88,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 80
	AddPlayerClass(87,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 81
	AddPlayerClass(89,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 82
	AddPlayerClass(90,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 83
	AddPlayerClass(92,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 84
	AddPlayerClass(93,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 85
	AddPlayerClass(94,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 86
	AddPlayerClass(95,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 87
	AddPlayerClass(96,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 89
	AddPlayerClass(97,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 90
	AddPlayerClass(98,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 91
	AddPlayerClass(99,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 92
	AddPlayerClass(100,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 93
	AddPlayerClass(101,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 94
	AddPlayerClass(102,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 95
	AddPlayerClass(103,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 96
	AddPlayerClass(104,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 97
	AddPlayerClass(105,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 98
	AddPlayerClass(106,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 99
	AddPlayerClass(107,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 100
	AddPlayerClass(108,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 101
	AddPlayerClass(109,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 102
	AddPlayerClass(110,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 103
	AddPlayerClass(111,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 104
	AddPlayerClass(112,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 105
	AddPlayerClass(113,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 106
	AddPlayerClass(114,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 107
	AddPlayerClass(115,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 108
	AddPlayerClass(116,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 109
	AddPlayerClass(117,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 110
	AddPlayerClass(118,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 111
	AddPlayerClass(119,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 112
	AddPlayerClass(120,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 113
	AddPlayerClass(121,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 114
	AddPlayerClass(122,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 115
	AddPlayerClass(123,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 116
	AddPlayerClass(124,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 117
	AddPlayerClass(125,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 118
	AddPlayerClass(126,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 119
	AddPlayerClass(127,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 120
	AddPlayerClass(128,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 121
	AddPlayerClass(130,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 122
	AddPlayerClass(131,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 123
	AddPlayerClass(132,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 124
	AddPlayerClass(133,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 125
	AddPlayerClass(100,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 126
	AddPlayerClass(190,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 127
	AddPlayerClass(136,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 128
	AddPlayerClass(155,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 129
	AddPlayerClass(138,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 130
	AddPlayerClass(139,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 131
	AddPlayerClass(140,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 132
	AddPlayerClass(141,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 133
	AddPlayerClass(142,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 134
	AddPlayerClass(143,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 135
	AddPlayerClass(144,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 136
	AddPlayerClass(145,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 137
	AddPlayerClass(146,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 138
	AddPlayerClass(265,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 139
	AddPlayerClass(266,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 140
	AddPlayerClass(267,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 141
	AddPlayerClass(268,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 142
	AddPlayerClass(269,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 143
	AddPlayerClass(270,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 144
	AddPlayerClass(271,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 145
	AddPlayerClass(272,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 146
	AddPlayerClass(273,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 147
	AddPlayerClass(274,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 148
	AddPlayerClass(275,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 149
	AddPlayerClass(276,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 150
	AddPlayerClass(277,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 151
	AddPlayerClass(278,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 152
	AddPlayerClass(279,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 153
	AddPlayerClass(280,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 154
	AddPlayerClass(281,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 155
	AddPlayerClass(282,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 156
	AddPlayerClass(283,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 157
	AddPlayerClass(284,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 158
	AddPlayerClass(285,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 159
	AddPlayerClass(286,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 160
	AddPlayerClass(287,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 161
	AddPlayerClass(288,1285.8182,-1349.8336,13.5676,95.4816,0,0,0,0,-1,-1);// Humano 162
	return 1;
}

stock ToggleTagName(playerid, toggle)
{
    foreach(new I:Player)
    {
        if(I != INVALID_PLAYER_ID)
        {
            ShowPlayerNameTagForPlayer(I, playerid, toggle);
        }
    }
}

stock StealthMode(playerid)
{
    Hidden{playerid} = true;
    ToggleTagName(playerid, 0);

	SetPlayerColor(playerid, GetPlayerColor(playerid) & ~0xFF);

    Delete3DTextLabel(PInfo[playerid][Ranklabel]);

    SetPlayerAttachedObject
    (
            playerid,
            6,
            ObjectInfo[CurrentObject{playerid}][o_id],
            ObjectInfo[CurrentObject{playerid}][o_b],
            ObjectInfo[CurrentObject{playerid}][o_x],
            ObjectInfo[CurrentObject{playerid}][o_y],
            ObjectInfo[CurrentObject{playerid}][o_z],
            ObjectInfo[CurrentObject{playerid}][o_rx],
            ObjectInfo[CurrentObject{playerid}][o_ry],
            ObjectInfo[CurrentObject{playerid}][o_rz],
            ObjectInfo[CurrentObject{playerid}][o_sx],
            ObjectInfo[CurrentObject{playerid}][o_sy],
            ObjectInfo[CurrentObject{playerid}][o_sz]
    );
}

stock RevealPlayer(playerid, toggle = 1)
{
    Hidden{playerid} = false;
    SetPlayerColor(playerid, green);
    RemovePlayerAttachedObject(playerid, 6);
    ToggleTagName(playerid, toggle);
    new string2[45];
	if(PInfo[playerid][Premium] == 1) {
		format(string2,sizeof string2,""cgold"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }
	else if(PInfo[playerid][Premium] == 2) {
	    format(string2,sizeof string2,""cplat"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }
	else {
	    format(string2,sizeof string2,""cgreen"Rank: %i | XP: %i/%i",PInfo[playerid][Rank],PInfo[playerid][XP],PInfo[playerid][XPToRankUp]); }

	PInfo[playerid][Ranklabel] = Create3DTextLabel(string2, green, 0, 0, 0, 30.0, 0);
	Attach3DTextLabelToPlayer(PInfo[playerid][Ranklabel], playerid, 0.0, 0.0, 0.3);
	return 1;
}

function OnPlayerCBug(playerid) {
    //new Float:PS[3];
    if(CBugTimes[playerid] >= 2)
    {
        new str[128];
        format(str, sizeof str, "[Anti C-Bug] "cred"%s (ID: %d) is doing C-Bug, keep an eye on him. (/spec)", GetPName(playerid), playerid);
	    SendAdminMessage(white, str);
	    SendClientMessage(playerid, white, "[Anti C-Bug] "cred"Do not C-Bug. You can be punished for that.");
	    CheckCrouch[playerid] = 0;
		CBugTimes[playerid] = 0;
	    //GetPlayerPos(playerid,PS[0],PS[1],PS[2]);
	    //SetPlayerPos(playerid,PS[0],PS[1],PS[2]+4);
	}
    return 1;
}

function CrouchCheck(playerid) {
    CheckCrouch[playerid] = 0;
    return 1;
}

/*function SlapPlayer(playerid)
{
	BunnyHop[playerid] = 0;
	ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff",4.1, 0, 1, 1, 0, 0);

	if(BunnyHopMSG[playerid] == 0)
	{
	    SendClientMessage(playerid, white, "[Anti BH] "cred"You just have fallen to the floor because you are doing BunnyHop.");
	    BunnyHopMSG[playerid] = 1;
	}
	return 1;
}

function CheckBH(playerid)
{
    if(BunnyHop[playerid] >= 1) BunnyHop[playerid] = 0;
	return 1;
}*/

UpdatePlayerGuide(playerid)
{
	if(!PInfo[playerid][P_INTRO_GUIDE_OPTION])
	{
		PlayerTextDrawSetString(playerid, PTD_INTRO_GUIDE[playerid],
		"The_objective_of_the_humans_team_is_to_complete_all_the_8~n~checkpoints_scattered_around_the_map.\
		~n~~n~Staying_in_higher_places_will_increase_your_chances_of_surviving.~n~Join_forces_with_your_team_to_win.~n~\
		Make_a_good_use_of_your_ammo.~n~Each_level_has_an_ability.~n~Press_Y_to_change_your_perk_and_N_to_open_your_inventory.~n~~n~\
		You_can_search_for_items_inside_interiors_by_pressing_C_key.~n~In_order_to_win,_the_humans_team_has_to_complete_all_the~n~checkpoints_around_the_map.~n~~n~"
		);
	}
	else
	{
		PlayerTextDrawSetString(playerid, PTD_INTRO_GUIDE[playerid],
		"As a zombie, you have to infect the humans.~n~\
		Right click near a human to bite him.~n~~n~\
		The zombies team objective is to infect all the humans alive.~n~\
		Press Y to change your perk, as a zombie you don't an inventory.~n~~n~\
		In order to win, the infection has to reach 100%.~n~~n~"
		);
	}
	return 1;
}

stock DropItem(playerid, object, Float:tolerance, Float:inFrontEnd, Float:inFront, Float:rotateX, Float:rotateY)
{
    new Float:x, Float:y, Float:z, Float:caZ;
    GetPlayerPos(playerid, x, y, z);
    DestroyObject(dropitem);
    GetXYInFrontOfPlayer(playerid, x, y, inFront);
    dropitem = CreateObject(object, x, y, z, rotateX, rotateY, 90.0);
    GetXYInFrontOfPlayer(playerid, x, y, inFrontEnd);
    MoveObject(dropitem, x, y, z+0.8, 5.80);
    PInfo[playerid][ZObject] = dropitem;
    //GetXYInFrontOfPlayer(playerid, x, y, inFront);
    CA_FindGroundZ(x, y, z, caZ);
	ApplyAnimation(playerid,"GRENADE","WEAPON_throwu",3.0,0,0,0,0,0);
	SetTimerEx("MoveItem", 200, false, "iffff", playerid, x, y, caZ, tolerance);
	return 1;
}

forward MoveItem(playerid, Float:x, Float:y, Float:caZ, Float:tolerance);
public MoveItem(playerid, Float:x, Float:y, Float:caZ, Float:tolerance)
{
    MoveObject(dropitem, x, y, caZ+(tolerance), 7.70);
    PInfo[playerid][ZX] = x, PInfo[playerid][ZY] = y, PInfo[playerid][ZZ] = caZ+(tolerance);
	return 1;
}


stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

stock CA_FindGroundZ(Float:x, Float:y, Float:z, &Float:gZ)
{
    CA_RayCastLine(x, y, z, x, y, z-1000.0, gZ, gZ, gZ);

    return 0;
}

public OnPlayerAirbreak(playerid)
{
	if(PInfo[playerid][Level] > 4) return 1;
    new string[128], str[64];
    format(string, sizeof(string), " || Gamemode detected %s cheating and he has been banned - Reason: Airbreaking ||.",GetPName(playerid));
    SendClientMessageToAll(red, string);
    SendClientMessage(playerid,red, "It's an error? Take a screenshot (F8), go to www.eternal-games.net and apply to get unbanned.");
    format(string, sizeof(string), " || Gamemode detected %s cheating - Reason: Airbreaking ||.",GetPName(playerid));
    SendAdminMessage(red, string);

	format(DB_Query, sizeof(DB_Query), "");
	strcat(DB_Query, "UPDATE USERS SET ");
	format(str, 64, "BANNED = '%d'", 1); strcat(DB_Query, str);
    format(str, 64, " WHERE NAME = '%s'", GetPName(playerid)); strcat(DB_Query, str);
	db_query(Database, DB_Query);

    P_BanEx(playerid, "Airbreak");
    SaveIn("Banlog",string,1);
    return 1;
}

function CheckPing(playerid)
{
    if(GetPlayerPing(playerid) > MAX_PING)
	{
	    if(PInfo[playerid][P_STATUS] == PS_SPAWNED)
	    {
		    new st[128];
		    format(st, sizeof st, "|| "cred"%s (ID: %d) has been kicked from the server. Reason: Ping higher than 1000. "cwhite"||", GetPName(playerid), playerid);
		    SendClientMessageToAll(white, st);

		    SendClientMessage(playerid, white, "|| "cred"You have been kicked. Your ping is higher than 1000. "cwhite"||");

			KickEx(playerid);
			return 1;
		}
	}
	return 1;
}

function ObjectsLoaded(playerid)
{
	if(Team[playerid] == 2) TogglePlayerControllable(playerid, true);
	return 1;
}

stock GetWeaponNameByID(wid)
{
    new gunname[32];
    switch (wid)
    {
        case    1 .. 17,
                22 .. 43,
                46 :        GetWeaponName(wid,gunname,sizeof(gunname));
        case    0:          format(gunname,32,"%s","Fist");
        case    18:         format(gunname,32,"%s","Molotov Cocktail");
        case    44:         format(gunname,32,"%s","Night Vis Goggles");
        case    45:         format(gunname,32,"%s","Thermal Goggles");
        default:            format(gunname,32,"%s","Invalid Weapon Id");

    }
    return gunname;
}

function FakekillT()
{
	foreach(new playerid:Player)
	{
		if(!IsPlayerConnected(playerid)) continue;
		//new str[64];
	    //Fakekill[playerid]--;
	    if(Fakekill[playerid] > 2)
	    {
			SendClientMessage(playerid,white, "[Anti FakeKill] "cred"You have been kicked. Reason: Fakekill");
	  		//SendClientMessage(playerid,red, "It's an error? Take a screenshot (F8), go to www.eternal-games.net and apply to get unbanned.");
			SendFMessageToAll(white, "[Anti FakeKill] "cred"%s has been kicked for doing fake kill.", GetPName(playerid));
			/*
			format(DB_Query, sizeof(DB_Query), "");
			strcat(DB_Query, "UPDATE USERS SET ");
			format(str, 64, "BANNED = '%d'", 1); strcat(DB_Query, str);
		    format(str, 64, " WHERE NAME = '%s'", GetPName(playerid)); strcat(DB_Query, str);
			db_query(Database, DB_Query);

	        BanEx(playerid, "FakeKill");
			*/
	        KickEx(playerid);
	    } else {
			Fakekill[playerid] = 0;
	 	}
	}
    return 1;
}

function CheatBan(playerid, reason[])
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(PInfo[playerid][Logged] != 1) return 1;
	new str[128];
	SendFMessage(playerid, white, "[Anti Cheats] "cred"You have been banned from the server for using cheats ( %s ) "cwhite"||", reason[0]);
	SendClientMessage(playerid,red, "It's an error? Take a screenshot (F8), go to www.eternal-games.net and apply to get unbanned.");
	format(str, sizeof str, "|| Gamemode detected %s (ID: %d) cheating - Reason: %s ||", GetPName(playerid), playerid, reason);
	SendAdminMessage(red, str);

	format(DB_Query, sizeof(DB_Query), "");
	strcat(DB_Query, "UPDATE USERS SET ");
	format(str, 64, "BANNED = '%d'", 1); strcat(DB_Query, str);
    format(str, 64, " WHERE NAME = '%s'", GetPName(playerid)); strcat(DB_Query, str);
	db_query(Database, DB_Query);

	SetTimerEx("BanPlayer2", 50, 0, "is", playerid, "Cheats Detected!");
	return 1;
}

stock ZombiesIngame()
{
    new infects;
	for(new i; i < MAX_PLAYERS;i++)
	{
	    if(!IsPlayerConnected(i)) continue;
		if(PInfo[i][P_STATUS] != PS_SPAWNED) continue;
	    if(PInfo[i][Firstspawn] == 1) continue;
	    if(PlayerState[i] == false) continue;
	    if(Team[i] == ZOMBIE) infects++;
	}
	return 1;
}

function Unjail(playerid)
{
	if(Jailed[playerid] == 0) return 1;
    Jailed[playerid] = 0;
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SpawnPlayer(playerid);
	SetPlayerHealth(playerid, 100);
	KillTimer(JailTimer[playerid]);
	return 1;
}

GetNumberOfPlayersOnThisIP(test_ip[])
{
	new against_ip[32+1],x = 0,ip_count = 0;
	for(x = 0; x < MAX_PLAYERS; x++)
	{
		if(IsPlayerConnected(x))
		{
		    GetPlayerIp(x,against_ip,32);
		    if(!strcmp(against_ip,test_ip))
				ip_count++;
		}
	}
	return ip_count;
}

stock SetPlayerForwardVelocity(playerid, Float:Velocity, Float:Z)
{
	if(!IsPlayerConnected(playerid)) return false;
	new Float:Angle;
	new Float:SpeedX, Float:SpeedY;
	GetPlayerFacingAngle(playerid, Angle);
	SpeedX = floatsin(-Angle, degrees);
	SpeedY = floatcos(-Angle, degrees);
	SetPlayerVelocity(playerid, floatmul(Velocity, SpeedX), floatmul(Velocity, SpeedY), Z);
	return true;
}

function MoveAirItem(Float:x, Float:y, Float:caZ, Float:tolerance)
{
    MoveObject(airdropitem, x, y, caZ+(tolerance), 7.70);
    caZAirdrop2 = caZ+(tolerance);
	return 1;
}

function AirDropTimer()
{
	if(AirDroppedItem{airdropitem} == true) return 1;
	new Float:NPCPos[3];
	GetVehiclePos(NPCVehicle3, NPCPos[0], NPCPos[1], NPCPos[2]);

    DestroyObject(airdropitem);
    airdropitem = CreateObject(18849, NPCPos[0], NPCPos[1], NPCPos[2], 0.0, 0.0, 90.0);

    MoveObject(airdropitem, NPCPos[0], NPCPos[1], NPCPos[2]+0.8, 5.80);
    CA_FindGroundZ(NPCPos[0], NPCPos[1], NPCPos[2], caZAirdrop);

    AirDroppedItem{airdropitem} = true;

	SetTimerEx("MoveAirItem", 200, false, "ffff", NPCPos[0], NPCPos[1], caZAirdrop+7.3, -0.01);

    SendClientMessageToAll(white, "** {009CBB}RADIO: AirDrop "cwhite"!");
	SendClientMessageToAll(white, "» LOCUTOR: {5CA488}Sgt Nikolei has thrown a bag with subministers.");
	SendClientMessageToAll(white, "» LOCUTOR: {5CA488}Find that bag to get items.");

	new rand = random(3);
	if(rand == 0) AirDTimer = SetTimer("AirDropTimer", 900000, true);
	else if(rand == 1) AirDTimer = SetTimer("AirDropTimer", 600000, true);
	else if(rand == 2) AirDTimer = SetTimer("AirDropTimer", 720000, true);
	return 1;
}

function HalloweenEvent()
{
	new
		string[256],
		rand = random(sizeof(RandomPositions));

	if(Winner == 0) {
		DestroyDynamicPickup(Pumpkin);
		SendClientMessageToAll(-1, "Nobody has found the pumpkin.");
	}

	Winner = 0;
	Number = rand;
	Pumpkin = CreateDynamicPickup(19320, 23, RandomPositions[rand][0], RandomPositions[rand][1], RandomPositions[rand][2]);

	SendClientMessageToAll(COLOR_DARKMAUVE, "[ » ] Halloween Event [ « ]");
	format(string, sizeof(string), "» A new pumpkin was hidding in the area: %s.", LocationsName[rand]);
	SendClientMessageToAll(COLOR_MAUVE, string);
	SendClientMessageToAll(COLOR_MAUVE, "» You have 10 minutes to find this pumpkin.");

    PumpkinOn = 1;

	new Hour, Minute, Second;
	gettime(Hour, Minute, Second);
	Minutes = Minute;
	return 1;
}

function StreakTimer(playerid,killerid)
{
	if(Fakekill[playerid] == 0)
	{
    	switch(Streaks[killerid])
    	{
			case 3:
			{
		    	SendFMessageToAll(0xA4A4A4FF, "[KILLINGSPREE] Triple Kill for %s!", GetPName(killerid));
			}
			case 5:
			{
			    SendFMessageToAll(0xA4A4A4FF, "[KILLINGSPREE] %s is dominating with five kills!", GetPName(killerid));
			}
			case 7:
			{
				SendFMessageToAll(0xA4A4A4FF, "[KILLINGSPREE] RAMPAGE for %s with seven kills!", GetPName(killerid));
			}
			case 8:
			{
				SendFMessageToAll(0xA4A4A4FF, "[KILLINGSPREE] %s is unbelievable with eight kills!", GetPName(killerid));
			}
			case 9:
			{
			    SendFMessageToAll(0xA4A4A4FF, "[KILLINGSPREE] %s is worldclass, nine kills!", GetPName(killerid));
			}
			case 10:
			{
			    SendFMessageToAll(0xA4A4A4FF, "[KILLINGSPREE] %s is annihilating with ten kills!", GetPName(killerid));
			}
			case 15:
			{
			    SendFMessageToAll(0xA4A4A4FF, "[KILLINGSPREE] %s is the damn boss with fifteen kills!", GetPName(killerid));
			}
			case 20:
			{
			    SendFMessageToAll(0xA4A4A4FF, "[KILLINGSPREE] Omg, %s is ravaging all with Twenty kills", GetPName(killerid));
			}
		}
	}
	return 1;
}

public
	IRC_OnConnect(botid)
{
	printf("[IRC] Bot ID %d connected.", botid);
	// Join the channel
	IRC_JoinChannel(botid, IRC_CHANNEL);
	// Add the bot to the group
	IRC_AddToGroup(gGroupID, botid);
	return 1;
}

/*
	Note that this callback is executed whenever a current connection is closed
	OR whenever a connection attempt fails. Reconnecting too fast can flood the
	IRC server and possibly result in a ban. It is recommended to set up
	connection reattempts on a timer, as demonstrated here.
*/

public
	IRC_OnDisconnect(botid)
{
	printf("[IRC] Bot ID %d desconnected", botid);
	if (botid == gBotID[0])
	{
		// Reset the bot ID
		gBotID[0] = 0;
		// Wait 20 seconds for the first bot
		SetTimerEx("IRC_ConnectDelay", 20000, 0, "d", 1);
	}
	else if (botid == gBotID[1])
	{
		// Reset the bot ID
		gBotID[1] = 0;
		// Wait 25 seconds for the second bot
		SetTimerEx("IRC_ConnectDelay", 25000, 0, "d", 2);
	}
	printf("[IRC] Bot ID %d is trying to connect...", botid);
	// Remove the bot from the group
	IRC_RemoveFromGroup(gGroupID, botid);
	return 1;
}

public
	IRC_OnJoinChannel(botid, channel[])
{
	printf("[IRC] Bot ID %d joined the channel %s.", botid, channel);
	return 1;
}

/*
	If the bot cannot immediately rejoin the channel (in the event, for example,
	that the bot is kicked and then banned), you might want to set up a timer
	here as well for rejoin attempts.
*/

public
	IRC_OnLeaveChannel(botid, channel[], message[])
{
	printf("[IRC] Bot ID %d has left the channel %s (%s)!", botid, channel, message);
	IRC_JoinChannel(botid, channel);
	return 1;
}

public
	IRC_OnUserDisconnect(botid, user[], host[], message[])
{
	printf("[IRC] %s desconected. (%s)", user, message);
	return 1;
}

public
	IRC_OnUserJoinChannel(botid, channel[], user[], host[])
{
	printf("[IRC] %s has joined the channel %s.", user, channel);
	return 1;
}

public
	IRC_OnUserLeaveChannel(botid, channel[], user[], host[], message[])
{
	printf("[IRC](Bot ID %d): User %s (%s) has left the channel %s (%s)!", botid, user, host, channel, message);
	return 1;
}

public
	IRC_OnUserNickChange(botid, oldnick[], newnick[], host[])
{
	printf("[IRC](Bot ID %d): User %s (%s) has changed his name for %s.", botid, oldnick, host, newnick);
	return 1;
}

public
	IRC_OnUserSetChannelMode(botid, channel[], user[], host[], mode[])
{
	printf("[IRC] %s of the channel %s changed the Mode to %s.", user, channel, mode);
	return 1;
}

public
	IRC_OnUserSetChannelTopic(botid, channel[], user[], host[], topic[])
{
	printf("[IRC]%s of the channel %s changed the topic to %s.", user, channel, topic);
	return 1;
}

public
	IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
	printf("[IRC] %s says: %s", user, message);
	// Someone sent the first bot a private message
	if (!strcmp(recipient, BOT_1_NICKNAME))
	{
		IRC_Say(botid, user, "You sent me a message.");
	}
	return 1;
}

public
	IRC_OnUserNotice(botid, recipient[], user[], host[], message[])
{
	printf("*** IRC_OnUserNotice (Bot ID %d): User %s (%s) has sent a notice %s: %s", botid, user, host, recipient, message);
	// Someone sent the second bot a notice (probably a network service)
	if (!strcmp(recipient, BOT_2_NICKNAME))
	{
		IRC_Notice(botid, user, "You sent me a notice!");
	}
	return 1;
}

/*
	This callback is useful for logging, debugging, or catching error messages
	sent by the IRC server.
*/

public
	IRC_OnReceiveRaw(botid, message[])
{
	new
		File:file;
	if (!fexist("irc_log.txt"))
	{
		file = fopen("irc_log.txt", io_write);
	}
	else
	{
		file = fopen("irc_log.txt", io_append);
	}
	if (file)
	{
		fwrite(file, message);
		fwrite(file, "\r\n");
		fclose(file);
	}
	return 1;
}

/*
	Some examples of channel commands are here. You can add more very easily;
	their implementation is identical to that of ZeeX's zcmd.
*/

IRCCMD:say(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least voice in the channel
	if (IRC_IsVoice(botid, channel, user))
	{
		// Check if the user enteCOLOR_ROJO any text
		if (!isnull(params))
		{
			new
				msg[128];
			// Echo the formatted message
			format(msg, sizeof(msg), "02*** %s on IRC: %s", user, params);
			IRC_GroupSay(gGroupID, channel, msg);
			format(msg, sizeof(msg), "* [IRC] %s: {FFFFFF}%s", user, params);
			SendClientMessageToAll(0x0076FFFF, msg);
		}
	}
	return 1;
}

IRCCMD:kick(botid, channel[], user[], host[], params[])
{
	// Check if the user is at least a halfop in the channel
	if (IRC_IsHalfop(botid, channel, user))
	{
		new
			playerid,
			reason[64];
		// If the user did not enter a player ID, then the command will not be processed
		if (sscanf(params, "dz", playerid, reason))
		{
			return 1;
		}
		// If the player is not connected, then nothing will be done
		if (IsPlayerConnected(playerid))
		{
			new
				msg[128],
				name[MAX_PLAYER_NAME];
			// If no reason is given, then "No reason" will be stated
			if (isnull(reason))
			{
				format(reason, sizeof(reason), "No reason");
			}
			// Echo the formatted message and kick the user
			GetPlayerName(playerid, name, sizeof(name));
			format(msg, sizeof(msg), "02*** %s has been kicked %s via IRC. (%s)", name, user, reason);
			IRC_GroupSay(gGroupID, channel, msg);
			format(msg, sizeof(msg), "*** %s has been kicked for %s via IRC. (%s)", name, user, reason);
			SendClientMessageToAll(0x0000FFFF, msg);
			KickEx(playerid);
		}
	}
	return 1;
}

IRCCMD:ann(botid, channel[], user[], host[], params[])
{
	// Check if the user has at least operator in the channel
	if (IRC_IsOp(botid, IRC_CHANNEL, user))
	{
		// Check if the user enteCOLOR_ROJO any text
		if (!isnull(params))
		{
			new
				msg[128];
			// Echo the formatted message
			format(msg, sizeof(msg), " %s you've sent a message: %s", user, params);
			IRC_GroupSay(botid, IRC_CHANNEL, msg);
			format(msg, sizeof(msg), "[eG] Announce: {FFFFFF}%s", params);
			SendClientMessageToAll(0xFFFF00AA, msg);
		}
	}
	return 1;
}

IRCCMD:ban(botid, channel[], user[], host[], params[])
{
	// Check if the user is at least an op in the channel
	if (IRC_IsOp(botid, channel, user))
	{
		new
			playerid,
			reason[64];
		// If the user did not enter a player ID, then the command will not be processed
		if (sscanf(params, "dz", playerid, reason))
		{
			return 1;
		}
		// If the player is not connected, then nothing will be done
		if (IsPlayerConnected(playerid))
		{
			new
				msg[128],
				name[MAX_PLAYER_NAME];
			// If no reason is given, then "No reason" will be stated
			if (isnull(reason))
			{
				format(reason, sizeof(reason), "None");
			}
			// Echo the formatted message and ban the user
			GetPlayerName(playerid, name, sizeof(name));
			format(msg, sizeof(msg), "02*** %s has been banned by %s via IRC. Reason: %s", name, user, reason);
			IRC_GroupSay(gGroupID, channel, msg);
			format(msg, sizeof(msg), "[IRC] %s has been banned by %s. Reason: %s", name, user, reason);
			SendClientMessageToAll(0x0000FFFF, msg);
			BanEx(playerid, reason);
		}
	}
	return 1;
}

IRCCMD:rcon(botid, channel[], user[], host[], params[])
{
	// Check if the user is at least an op in the channel
	if (IRC_IsOp(botid, channel, user))
	{
		// Check if the user enteCOLOR_ROJO any text
		if (!isnull(params))
		{
			// Check if the user did not enter any bad commands
			if (strcmp(params, "exit", true) != 0 && strcmp(params, "reloadfs irc", true) != 0)
			{
				// Echo the formatted message and send the command
				new
					msg[128];
				format(msg, sizeof(msg), "RCON command%s has been executed", params);
				IRC_GroupSay(gGroupID, channel, msg);
				SendRconCommand(params);
			}
		}
	}
	return 1;
}

function anti_wep_hax()
{
    for(new i = 0; i < MAX_PLAYERS;i++)
    {
        // we check if the player is valid.. add other stuff that you make have on your gm to check it.
        if(IsPlayerConnected(i) && !IsPlayerAdmin(i) && !IsPlayerNPC(i) )
        {

        	if(PInfo[i][P_STATUS] == PS_SPAWNED && PInfo[i][Level] == 0)
       	 	{
            	if(PInfo[i][Rank] > 0 && PInfo[i][Rank] <= 4)
            	{
                	new weapons[13][2];

                	for (new k = 1; k <= 12; k++)
                	{
                    	GetPlayerWeaponData(i, k, weapons[k][0], weapons[k][1]);

                    	if( (k == 4 || k == 5 || k == 6 || k == 7 || k == 9 || k == 11 || k == 12) && weapons[k][0] != 0 )
                    	{
							SendFMessageToAll(white, "[Anti-Cheats] "cred"''%s'' has been kicked from the server. (Reason: Wep Hack Detected!)", GetPName(i));
							KickEx(i);
                    	}
						else if(weapons[k][0] != 0 && weapons[k][1] != 0) // We make sure he has the weapon.
                    	{
                        	if(k == 1 && weapons[k][0] != WEAPON_POOLSTICK )
                        	{
                            	SendFMessageToAll(white, "[Anti-Cheats] "cred"''%s'' has been kicked from the server. (Reason: Wep Hack Detected!)", GetPName(i));
								KickEx(i);
                        	}
                        	else if(k == 2 && weapons[k][0] != WEAPON_SILENCED )
                        	{
                            	SendFMessageToAll(white, "[Anti-Cheats] "cred"''%s'' has been kicked from the server. (Reason: Wep Hack Detected!)", GetPName(i));
								KickEx(i);
                        	}
                        	else if(k == 3 && weapons[k][0] != WEAPON_SHOTGUN )
                        	{
                            	SendFMessageToAll(white, "[Anti-Cheats] "cred"''%s'' has been kicked from the server. (Reason: Wep Hack Detected!)", GetPName(i));
								KickEx(i);
                        	}
                        	else if(k == 8 && weapons[k][0] != WEAPON_MOLTOV)
                        	{
                            	SendFMessageToAll(white, "[Anti-Cheats] "cred"''%s'' has been kicked from the server. (Reason: Wep Hack Detected!)", GetPName(i));
								KickEx(i);
                        	}
                        	else if(k == 10)
                        	{
                            	//here.. he has the dildo probably.
                       	 	}
                    	}
                	}
            	}
        	}
		}
    }
}

stock GetSingleChar(const source[], num)
{
	new string[MAX_STRING];
	strmid(string,source,num,(num+1));
	return string;
}
stock is_number(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
    {
    	if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}

stock trim(str[])
{
    strtrim(str);
	new size = strlen(str);
	for(new i = 0; i < size - 1; i++)
	{
	    if(str[i] == ' ')
		{
		    new temp = i;
		    while(str[i] == ' ')
		        i++;
	        strdel(str, temp, i);
			i -= i - temp;
  		}
	}

}

stock anti_ip(string[])
{
	trim(string);
    new c[MAX_STRING];
	new number,dot;
	new bool:found = false;
	for(new i = 0,sz = strlen(string); i < sz; i++)
	{
		c = GetSingleChar(string,i);
		if(is_number(c))
		{
			number++;
			found = true;
		}
		else if(c[0] == '.' && number > 0)
		{
		    dot++;
		}
		if(found == true && number == 1)
		{
		    sz = i + 15;
		}
	}
	if(number >= 6 && dot >= 3)
	{
	    return 1;
	}
	return 0;
}

function ZHideAgain(playerid) CanHide{playerid} = true;
function KickPlayer(playerid) Kick(playerid);
function BanPlayer2(playerid, reason[]) BanEx(playerid, reason);
stock P_BanEx(playerid, reason[]) SetTimerEx("BanPlayer2", 150, 0, "is", playerid, reason);
