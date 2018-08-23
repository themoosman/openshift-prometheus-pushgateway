# OpenShift Prometheus Pushgateway

## Table of Contents

* [Overview](#overview)
* [License](#license)
* [Bill of Materials](#bill-of-materials)
* [Setup Instructions](#setup-instructions)
* [Presenter Notes](#presenter-notes)
    * [Environment Setup](#environment-setup)
    * [Clone the Git Repository](#clone-the-git-repository)
    * [Create Objects](#create-objects)
    * [Start Docker Build](#start-docker-build)
    * [Update Prometheus ConfigMap](#update-prometheus-configmap)
    * [Test the Pushgateway](#test-the-pushgateway)
      * [Validate the metric in Pushgateway](#validate-the-metric-in-pushgateway)
      * [Validate the metric in Prometheus](#validate-the-metric-in-prometheus)
* [Resources](#resources)
* [Contributing](#contributing)

## Overview
The following repositor shows how to setup a [Prometheus Pushgateway](https://prometheus.io/docs/practices/pushing/) in OpenShift.
The source for the Prometheus Pushgateway can be found [here](https://github.com/prometheus/pushgateway).

## License
The project utilizes code licensed under the terms of the Apache Software
License and therefore is licensed under ASL v2 or later.

This program is free software: you can redistribute it and/or modify it under
the terms of the Apache Software License version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the Apache Software License for more details.

You should have received a copy of the Apache Software License along with this
program. If not, see http://www.apache.org/licenses/LICENSE-2.0.html


## Bill of Materials

### Environment Specifications

This quickstart should be run on an installation of OpenShift Enterprise V3 with an existing Prometheus deployment.

## Setup Instructions

The project contains a single template file `(template/prometheus-pushgateway-template.yaml)` that creates all the necessary objects.

### Environment Setup

The Prometheus stack should already be configured in the `openshift-metrics` namespace.

### Clone the Git Repository
```bash
cd ~/git
git clone https://github.com/themoosman/openshift-prometheus-pushgateway.git
cd openshift-prometheus-pushgateway
```

### Create Objects
Process the temaplate to create the necessary objects, update the `ROUTE_URL` as necessary.
```bash
oc project openshift-metrics
oc process -f templates/prometheus-pushgateway-template.yaml -p ROUTE_URL=pushgateway.apps.ocp.example.com  | oc create -f -
```

### Start Docker Build
Start the build.
```bash
oc start-build prometheus-pushgateway --follow
```

### Update Prometheus ConfigMap
Currently this is manual, so PRs are greatly appreciated.
```bash
oc edit configmap prometheus
```

Add this yaml block as an additional scrape config.
```yaml
- job_name: 'pushgateway'
  honor_labels: true

  kubernetes_sd_configs:
    - role: service

  relabel_configs:
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_probe]
      action: keep
      regex: "pushgateway"
    - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
      action: keep
      regex: true
    - action: labelmap
      regex: __meta_kubernetes_node_label_(.+)
    - source_labels: [__name__]
      action: replace
      regex: (.+):(?:\d+);(\d+)
      replacement: ${1}:${2}
      target_label: __address__
```

Recycle the Prometheus pod to make sure the ConfigMap is updated.
```bash
oc delete pod -l app=prometheus
```

### Test the Pushgateway
Push a metric to the gateway.
```bash
echo "test_metric 1.00" | curl -k --data-binary @- https://pushgateway.apps.ocp.example.com/metrics/job/test_job
```

#### Validate the metric in Pushgateway
Visit the Pushgateway and search for metric.
![Pushgateway](images/pushgateway.png?raw=true "Pushgateway")

#### Validate the metric in Prometheus
Visit Prometheus and query for the metric.
![Prometheus](images/prometheus.png?raw=true "Prometheus")

## Resources
* [Prometheus Pushgateway Source](https://github.com/prometheus/pushgateway)
* [Prometheus Pushgateway](https://prometheus.io/docs/practices/pushing/)
* [Monitoring multiple federated clusters with Prometheus](https://banzaicloud.com/blog/prometheus-federation/)


## Contributing
Anyone is encouraged to contribute to the project by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.
