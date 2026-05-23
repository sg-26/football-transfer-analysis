import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('mysql+mysqlconnector://root:YOURPASSWORD@localhost/football_db')

# --- TRANSFERS ---
transfers = pd.read_csv(r'C:\Users\user\OneDrive\Desktop\football-transfer-analysis\data\processed\transfers_cleaned.csv')
print("Transfers shape:", transfers.shape)
print("Transfers columns:", transfers.columns.tolist())
transfers.to_sql('transfers', engine, if_exists='replace', index=False)
print("Transfers loaded.\n")

# --- CLUBS ---
clubs = pd.read_csv(r'C:\Users\user\OneDrive\Desktop\football-transfer-analysis\data\raw\clubs.csv')
clubs = clubs[['club_id', 'name', 'domestic_competition_id', 
               'total_market_value', 'squad_size', 'average_age',
               'stadium_name', 'net_transfer_record']]
print("Clubs shape:", clubs.shape)
clubs.to_sql('clubs', engine, if_exists='replace', index=False)
print("Clubs loaded.\n")

# --- PLAYERS ---
players = pd.read_csv(r'C:\Users\user\OneDrive\Desktop\football-transfer-analysis\data\raw\players.csv')
players = players[['player_id', 'name', 'date_of_birth', 'position', 
                   'sub_position', 'country_of_birth', 'country_of_citizenship',
                   'height_in_cm', 'market_value_in_eur', 
                   'highest_market_value_in_eur', 'current_club_name']]
print("Players shape:", players.shape)
players.to_sql('players', engine, if_exists='replace', index=False)
print("Players loaded.\n")

# --- APPEARANCES ---
appearances = pd.read_csv(r'C:\Users\user\OneDrive\Desktop\football-transfer-analysis\data\raw\appearances.csv',
                          usecols=['appearance_id', 'player_id', 'player_name',
                                   'date', 'goals', 'assists', 'yellow_cards',
                                   'red_cards', 'minutes_played'],
                          nrows=500000)  # cap at 500k rows
print("Appearances shape:", appearances.shape)
appearances.to_sql('appearances', engine, if_exists='replace', index=False)
print("Appearances loaded.\n")

print("All tables loaded successfully.")