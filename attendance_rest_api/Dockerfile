FROM public.ecr.aws/lambda/python:3.9
# Copy function code
COPY ./app ${LAMBDA_TASK_ROOT}
# Install the function's dependencies using file requirements.txt
# from your project folder.
COPY requirements.txt .
RUN pip install -r requirements.txt
EXPOSE 8000
# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "main.handler" ]