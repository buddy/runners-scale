### Description

The calculator is a [custom action](https://buddy.works/docs/pipelines/custom-actions) that calculates the number of builds (load) in your Buddy On-Premises infrastructure and informs whether you need to add or remove workers.

### Configuration

1. Fork this repository to your GitHub account.
2. Create a new project in Buddy and synchronize it with the repository.
3. The action will be automatically added to your action list for use across the whole workspace.

### Input

In the input, you provide:

- `WORKER_TAG` – The tag for which the action calculates the workers. Leave empty if you want to scale untagged workers. [Learn how tagging works in Buddy](https://buddy.works/docs/on-premises/workers/workers-pipelines)
- `WORKER_SLOTS` – The number of concurrent slots per worker, i.e. how many pipelines or actions can be run at the same time. Leave empty to fetch the value your license settings.
- `MAX_WORKERS` – The maximum number of workers that can be launched in your on-premises infrastructure.
- `MIN_FREE_SLOTS` – The desired number of free slots in the instance. Used to calculate whether to add or remove workers for the given tag.

### Output

The input data is passed to `calc.sh` which generates three variables:

- `WORKER_TAG` – the worker tag for which the action was run
- `WORKER_SLOTS` – the number of concurrent slots per worker
- `WORKERS` – the optimal number of workers

### Preview in Buddy GUI

![buddy-worker-calculator](https://user-images.githubusercontent.com/8556342/217527631-9c496bfa-957f-469f-8f0c-d8c81d5d7cc3.png)

### Example pipeline

Here we can see a pipeline with the calculator action attached. The pipeline is run on schedule every 5 minutes for the branch `main`:

```yaml
- pipeline: Worker calculator
  on: SCHEDULE
  delay: 5
  start_date: "2023-01-01T00:00:00Z"
  refs:
    - "refs/heads/main"
  actions:
    - action: Calculate Workers
      type: CUSTOM
      custom_type: Workers_Scale:latest
      inputs:
        WORKER_TAG: ""
        WORKER_SLOTS: "2"
        MAX_WORKERS: "2"
        MIN_FREE_SLOTS: "1"
```

 The inputs describe the desired configuration of workers in the instance:

- the tag field is empty which means it refers to untagged workers only
- each worker in the instance has 2 concurrent slots
- 2 workers at max can be running at the same time
- 1 slot should always be available on every worker

### Data usage

The output of the action can be used to configure a process that will automatically scale your on-premises infrastructure. This repository contains an [example_pipeline](https://github.com/buddy/workers-scale/tree/main/example_pipeline) that uses Terraform to create and remove workers according to the number of available vs desired workers. Feel free to copy the pipeline and adapt it to your needs, or create your own scaling solution and share it with the community.
