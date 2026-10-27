//-----------------------------------------------------------------
// Main Game File
// C++ Source - Game.cpp - version v8_01
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Include Files
//-----------------------------------------------------------------
#include "Game.h"


//-----------------------------------------------------------------
// Game Member Functions																				
//-----------------------------------------------------------------

Game::Game() 																	
{
	// nothing to create
	
}

Game::~Game()																						
{
	// nothing to destroy
	
}

void Game::Initialize()			
{
	// Code that needs to execute (once) at the start of the game, before the game window is created

	AbstractGame::Initialize();
	GAME_ENGINE->SetTitle(_T("Tetris"));	
	
	GAME_ENGINE->SetWidth(300);
	GAME_ENGINE->SetHeight(600);



	m_lua.open_libraries(sol::lib::base, sol::lib::math);
	m_lua.script_file("script.lua");

	m_lua.new_usertype<GameEngine>("GameEngine",
		"DrawRect", &GameEngine::DrawRect,
		"IsKeyDown", &GameEngine::IsKeyDown,
		"GetFrameDelay", &GameEngine::GetFrameDelay,

		"FillRect", sol::overload(
			static_cast<bool (GameEngine::*)(int, int, int, int) const>(&GameEngine::FillRect)),

		"SetColor", sol::overload(
			static_cast<void (GameEngine::*)(int, int, int)>(&GameEngine::SetColor)),

		"DrawString", sol::overload(
			static_cast<int (GameEngine::*)(const tstring&, int, int) const>(&GameEngine::DrawString))
	);

	sol::function initializeGrid = m_lua["initializeGrid"];
	const auto funcResult = initializeGrid();
	if (!funcResult.valid())
	{
		//Handle Error
		const sol::error err = funcResult;
		std::cerr << "Lua Error: " << err.what();
	}

	//Set the font
	AddFontResourceEx(
		L"resources\\PublicPixel.ttf",
		FR_PRIVATE,
		nullptr
	);

	m_pFont = std::make_unique<Font>(L"Public Pixel", false, false, false, 20);
	GAME_ENGINE->SetFont(m_pFont.get());

	m_pAudio = std::make_unique<Audio>(L"resources\\TetrisTheme.mp3");
	m_pAudio->SetVolume(30);
	m_pAudio->SetRepeat(true);
	m_pAudio->Play(0, -1);
}

void Game::Start()
{
	// Insert code that needs to execute (once) at the start of the game, after the game window is created
}

void Game::End()
{
	// Insert code that needs to execute when the game ends
}

void Game::Paint(RECT rect) const
{
	sol::function paint = m_lua["Paint"];
	const auto funcResult = paint(GAME_ENGINE);
	if (!funcResult.valid())
	{
		//Handle Error
		const sol::error err = funcResult;
		std::cerr << "Lua Error: " << err.what();
	}
}

void Game::Tick()
{
	m_pAudio->Tick();

	sol::function update = m_lua["Update"];
	const auto funcResult = update(GAME_ENGINE);
	if (!funcResult.valid())
	{
		//Handle Error
		const sol::error err = funcResult;
		std::cerr << "Lua Error: " << err.what();
	}
}

void Game::MouseButtonAction(bool isLeft, bool isDown, int x, int y, WPARAM wParam)
{	
	// Insert code for a mouse button action

	/* Example:
	if (isLeft == true && isDown == true) // is it a left mouse click?
	{
		if ( x > 261 && x < 261 + 117 ) // check if click lies within x coordinates of choice
		{
			if ( y > 182 && y < 182 + 33 ) // check if click also lies within y coordinates of choice
			{
				GAME_ENGINE->MessageBox(_T("Clicked."));
			}
		}
	}
	*/
}

void Game::MouseWheelAction(int x, int y, int distance, WPARAM wParam)
{	
	// Insert code for a mouse wheel action
}

void Game::MouseMove(int x, int y, WPARAM wParam)
{	
	// Insert code that needs to execute when the mouse pointer moves across the game window

	/* Example:
	if ( x > 261 && x < 261 + 117 ) // check if mouse position is within x coordinates of choice
	{
		if ( y > 182 && y < 182 + 33 ) // check if mouse position also is within y coordinates of choice
		{
			GAME_ENGINE->MessageBox("Mouse move.");
		}
	}
	*/
}

void Game::CheckKeyboard()
{	

	sol::function CheckKeyBoard = m_lua["CheckKeyBoard"];
	const auto funcResult = CheckKeyBoard(GAME_ENGINE);
	if (!funcResult.valid())
	{
		//Handle Error
		const sol::error err = funcResult;
		std::cerr << "Lua Error: " << err.what();
	}
}

void Game::KeyPressed(TCHAR key)
{	
	// DO NOT FORGET to use SetKeyList() !!

	// Insert code that needs to execute when a key is pressed
	// The function is executed when the key is *released*
	// You need to specify the list of keys with the SetKeyList() function

	/*
		switch (key)
		{
		case _T('K'): case VK_LEFT:
			GAME_ENGINE->MessageBox(L"Moving left.");
			break;
		case _T('L'): case VK_DOWN:
			GAME_ENGINE->MessageBox(L"Moving down.");
			break;
		case _T('M'): case VK_RIGHT:
			GAME_ENGINE->MessageBox(L"Moving right.");
			break;
		case _T('O'): case VK_UP:
			GAME_ENGINE->MessageBox(L"Moving up.");
			break;
		case VK_ESCAPE:
			GAME_ENGINE->MessageBox(L"Escape menu.");
		}
	*/
}

void Game::CallAction(Caller* callerPtr)
{
	// Insert the code that needs to execute when a Caller (= Button, TextBox, Timer, Audio) executes an action
}







