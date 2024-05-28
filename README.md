### Description

The calculator is a [custom action](https://buddy.works/docs/pipelines/custom-actions) that calculates the number of builds (load) in your Buddy On-Premises infrastructure and informs whether you need to add or remove runners.

### Configuration

1. Fork this repository to your GitHub account.
2. Create a new project in Buddy and synchronize it with the repository.
3. The action will be automatically added to your action list for use across the whole workspace.

### Input

In the input, you provide:

- `RUNNER_TAG` – The tag for which the action calculates the runners. Leave empty if you want to scale untagged runners. [Learn how tagging works in Buddy](https://buddy.works/docs/on-premises/runners/runners-pipelines)
- `RUNNER_SLOTS` – The number of concurrent slots per runner, i.e. how many pipelines or actions can be run at the same time. Leave empty to fetch the value your license settings.
- `MAX_RUNNERS` – The maximum number of runners that can be launched in your on-premises infrastructure.
- `MIN_FREE_SLOTS` – The desired number of free slots in the instance. Used to calculate whether to add or remove runners for the given tag.

### Output

The input data is passed to `calc.sh` which generates three variables:

- `RUNNER_TAG` – the runner tag for which the action was run
- `RUNNER_SLOTS` – the number of concurrent slots per runner
- `RUNNERS` – the optimal number of runners

### Preview in Buddy GUI

![buddy-runner-calculator](/runners-scale-gui-preview.png)

### Example pipeline

Here we can see a pipeline with the calculator action attached. The pipeline is run on schedule every 5 minutes for the branch `main`:

```yaml
- pipeline: Runner calculator
  on: SCHEDULE
  delay: 5
  start_date: "2023-01-01T00:00:00Z"
  refs:
    - "refs/heads/main"
  actions:
    - action: Calculate Runners
      type: CUSTOM
      custom_type: Runners_Scale:latest
      inputs:
        RUNNER_TAG: ""
        RUNNER_SLOTS: "2"
        MAX_RUNNERS: "2"
        MIN_FREE_SLOTS: "1"
```

 The inputs describe the desired configuration of runners in the instance:

- the tag field is empty which means it refers to untagged runners only
- each runner in the instance has 2 concurrent slots
- 2 runners at max can be running at the same time
- 1 slot should always be available on every runner

### Data usage

The output of the action can be used to configure a process that will automatically scale your on-premises infrastructure. This repository contains an [example_pipeline](https://github.com/buddy/runners-scale/tree/main/example_pipeline) that uses Terraform to create and remove runners according to the number of available vs desired runners. Feel free to copy the pipeline and adapt it to your needs, or create your own scaling solution and share it with the community.
