import logging
import azure.functions as func

app = func.FunctionApp()


@app.function_name(name="HelloWorld")
@app.route(route="api/v1/hello", methods=["GET"])
def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    try:
        return func.HttpResponse("Hello World")
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return func.HttpResponse(
            "An unexpected error occurred.",
            status_code=500
        )
