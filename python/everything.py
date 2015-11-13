import plp_models
import analytics_setup
import sites

def drop_all(models, analytics_session):
    in_order = models.copy()
    in_order.reverse()

    for model in in_order:
        model.delete_rows(analytics_session)

def scrape(models, plp_session, analytics_session):
    for model in models:
        model.scrape(plp_session, analytics_session)

if __name__ == '__main__':
    plp_session = plp_models.create_session()
    analytics_session = analytics_setup.create_session()

    dimensions = [
        sites,
    ]

    drop_all(dimensions, analytics_session)

    scrape(dimensions, plp_session, analytics_session)
