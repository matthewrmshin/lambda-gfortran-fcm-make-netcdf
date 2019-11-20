"""Handler that calls a binary executable on AWS lambda."""


from subprocess import run


def handler(event, context):
    """Handle the lambda call."""
    proc = run([event['executable']], capture_output=True, cwd='/tmp')
    if proc.returncode:
        return {
            'statusCode': 500,
            'body': str(proc.stderr),
        }
    else:
        return {
            'statusCode': 200,
            'body': str(proc.stdout),
        }
