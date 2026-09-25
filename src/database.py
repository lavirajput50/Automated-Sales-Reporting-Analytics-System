from sqlalchemy import create_engine
import pandas as pd

def get_engine(user,password,host,port,dbname):
    try:
        connection_string = f"postgresql://{user}:{password}@{host}:{port}/{dbname}"
        engine=create_engine(connection_string)
        # test the connection
        with engine.connect( )as conn:
            print("Database connection successful.")
        return engine
    except Exception as e:
        print(f"Database connection failed:{e}")
        return None
def fetch_data(engine):
    if engine is None:
        print("Not valid engine provide")
        return None
    views = {
        'overall_summary': 'vm_overall_summary',
        'city_performance': 'vm_city_performance',
        'restaurant_cuisine': 'vm_restaurant_cuisine',
        'monthly_trend': 'vm_montly_revenue_profit',
        'quarter_trend': 'vm_quarter_revenue_profit',
        'customer_segment': 'customer_segment'
    }

    data={}
    for key,view_n in views.items():
        try:
            query=f"SELECT*FROM {view_n};"
            data[key]=pd.read_sql(query,engine)
            print(f'Fetched data from {view_n} ({len(data[key])} rows)')
        except Exception as e :
            print(f"Failed to fetch {view_n}:{e}")
            data[key]=pd.DataFrame()
    return data
    
e=get_engine(
    user='postgres',
    password='l12345',
    host='localhost',
    port='5433',
    dbname='SQL'
    
)
if e:
    report_data=fetch_data(e)
    