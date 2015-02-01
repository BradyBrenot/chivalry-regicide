class RegicideGame extends AOCTD;

var Controller CurrentKings[EAOCFaction];
var class<AOCFamilyInfo> KingClasses[EAOCFaction];
var CMWHudMarker KingMarkers[EAOCFaction];

function PerformOnFirstSpawn(Controller NewPlayer)
{
	if(RegicidePlayerController(NewPlayer) != none)
	{
		RegicidePlayerController(NewPlayer).ClientOnFirstSpawn();
	}

	super(AOCGame).PerformOnFirstSpawn(NewPlayer);
}

state AOCRoundInProgress
{	
	function ScoreKill( Controller Killer, Controller Other )
	{
		local int NewHighScore;
		local RegicidePlayerController RPC;
		local TeamInfo ScoringTeam;
		
		if(RegicidePRI(Other.PlayerReplicationInfo).bCurrentlyKing)
		{
			if(Other.PlayerReplicationInfo.Team == Teams[0])
			{
				ScoringTeam = Teams[1];
			}
			else
			{
				ScoringTeam = Teams[0];
			}

			NewHighScore = Max(CurHighestScore, ScoringTeam.Score);
			if (NewHighScore > CurHighestScore && NewHighScore < GoalScore)
			{
				if (PrevLeaderTeam == none || PrevLeaderTeam != ScoringTeam)
				{
					PrevLeaderTeam = ScoringTeam;
					BroadcastSystemMessage(4, class'AOCSystemMessages'.static.CreateLocalizationdata("Common", ScoringTeam.TeamIndex == EFAC_Agatha ? "AgathaKnights" : "MasonOrder", "AOCUI"),,EFAC_ALL);
				}
			}
			CurHighestScore = NewHighScore;
			
			RegicidePRI(Other.PlayerReplicationInfo).bCurrentlyKing = false;
			RegicidePRI(Other.PlayerReplicationInfo).CurrentKingFamily = none;
			CurrentKings[AOCPRI(Other.PlayerReplicationInfo).GetCurrentTeam()] = none;
			
			PickANewKing(AOCPRI(Other.PlayerReplicationInfo).GetCurrentTeam());
			
			foreach WorldInfo.AllControllers(class'RegicidePlayerController', RPC)
				RPC.NotifyKingKilled(AOCPRI(Other.PlayerReplicationInfo).GetCurrentTeam(), Other.PlayerReplicationInfo, CurrentKings[AOCPRI(Other.PlayerReplicationInfo).GetCurrentTeam()].PlayerReplicationInfo);
		}

		super(AOCGame).ScoreKill(Killer, Other);
	}
	
	function bool CheckScore(PlayerReplicationInfo Scorer)
	{
		if(Scorer.Team.Score >= GoalScore)
		{
			EndGame( Scorer, "Team Eliminated" );
			GotoState('PendingTDEnd');
		}
		
		return false;
	}
	
	function BeginState( Name PreviousStateName )
	{
		super.BeginState(PreviousStateName);
		
		if(CurrentKings[EFAC_Agatha] == none)
		{
			PickANewKing(EFAC_Agatha);
		}
		
		if(CurrentKings[EFAC_Mason] == none)
		{
			PickANewKing(EFAC_Mason);
		}
	}
	
	function RestartPlayer(Controller NewPlayer)
	{
		super.RestartPlayer(NewPlayer);
		
		if(CurrentKings[EFAC_Agatha] == none)
		{
			PickANewKing(EFAC_Agatha);
		}
		
		if(CurrentKings[EFAC_Mason] == none)
		{
			PickANewKing(EFAC_Mason);
		}
	}
}

function PickANewKing(EAOCFaction Faction)
{
	//Loop through Team's controllers, starting at a random index.
	// Look for one with least number of times being king
	// If we reach the point we started at, just set that player as king.
	// Bots can be kings too!
	
	local Controller C;
	local int StartIndex;
	local int BestTimesAsKing;
	local int BestIndex;
	local int i;
	
	local RegicidePlayerController RPC;
	local RegicideAICombatController RAI;
	
	local array<Controller> AllControllers;
	
	if(CurrentKings[Faction] != none)
	{
		return;
	}
	
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if(C.PlayerReplicationInfo.Team != none && C.PlayerReplicationInfo.Team.TeamIndex == int(Faction))
		{
			AllControllers.AddItem(C);
		}
	}
	
	BestTimesAsKing = 10000;
	BestIndex = -1;
	
	StartIndex = Rand(AllControllers.Length);
	BestIndex = StartIndex;
	BestTimesAsKing = RegicidePRI(AllControllers[i].PlayerReplicationInfo).TimesChosenAsKing;
	
	for(i = (StartIndex + 1) % AllControllers.Length; i != StartIndex; i = (i + 1) % AllControllers.Length)
	{
		C = AllControllers[i];
		
		if(RegicidePRI(C.PlayerReplicationInfo).TimesChosenAsKing < BestTimesAsKing)
		{
			BestTimesAsKing = RegicidePRI(C.PlayerReplicationInfo).TimesChosenAsKing;
			BestIndex = i;
		}
	}
	
	if(BestIndex != -1)
	{
		CurrentKings[Faction] = AllControllers[BestIndex];
	
		RPC = RegicidePlayerController(AllControllers[BestIndex]);
		RAI = RegicideAICombatController(AllControllers[BestIndex]);
		if(RPC != none)
		{
			RPC.NotifyChosenAsKing(KingClasses[Faction]);
		}
		else if(RAI != none)
		{
			RAI.NotifyChosenAsKing(KingClasses[Faction]);
		}
		
		RegicidePRI(CurrentKings[Faction].PlayerReplicationInfo).TimesChosenAsKing++;
	}		
}

function PerformOnSpawn(Controller C)
{
	local CMWHUDMarker NewMarker;
	local EAOCFaction Faction;
	
	super.PerformOnSpawn(C);

	if(RegicidePRI(C.PlayerReplicationInfo).bCurrentlyKing && C.Pawn != none)
	{
		Faction = RegicidePRI(C.PlayerReplicationInfo).GetCurrentTeam();
		if(KingMarkers[Faction] == none)
		{
			NewMarker = Spawn(class'CMWHUDMarker');
			KingMarkers[Faction] = NewMarker;
		}
		else
		{
			NewMarker = KingMarkers[Faction];
		}

		NewMarker.bDestroySelfIfBaseKilledOrDestroyed = true;
		NewMarker.bSetRelativeLocationFromBase = false;

		NewMarker.SetLocation(C.Pawn.Location);
		NewMarker.SetBase(C.Pawn);

		NewMarker.Enabled = true;
		NewMarker.bShowProgress = false;
		NewMarker.fMaxDistanceToShow = -1;

		NewMarker.FloatTextAgatha = "Defend";
		NewMarker.FloatTextMason = "Defend";
		NewMarker.ShowToTeam = Faction;
		NewMarker.bUseTextAsLocalizationKey = true;
		NewMarker.SectionName = "HudMarker";
		NewMarker.PackageName = "AOCMaps";
		NewMarker.AgathaImagePath = "img://UI_HUD_SWF.icon_defend_png";
		NewMarker.MasonImagePath = "img://UI_HUD_SWF.icon_defend_png";
	}
}

static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return default.class;
}

DefaultProperties
{
	KingClasses[EFAC_Agatha]=class'AOCFamilyInfo_Agatha_King'
	KingClasses[EFAC_Mason]=class'AOCFamilyInfo_Mason_King'
	
	DefaultAIControllerClass=class'RegicideAICombatController'
    PlayerControllerClass=class'RegicidePlayerController'
    DefaultPawnClass=class'RegicidePawn'
	PlayerReplicationInfoClass=class'RegicidePRI'
}