FROM openjdk:11

ARG SOURCE
ARG COMMIT_HASH
ARG COMMIT_ID
ARG BUILD_TIME
LABEL source=${SOURCE}
LABEL commit_hash=${COMMIT_HASH}
LABEL commit_id=${COMMIT_ID}
LABEL build_time=${BUILD_TIME}

# can be passed during Docker build as build time environment for github branch to pickup configuration from.
ARG spring_config_label

# can be passed during Docker build as build time environment for spring profiles active 
ARG active_profile

# can be passed during Docker build as build time environment for config server URL 
ARG spring_config_url

# can be passed during Docker build as build time environment for glowroot 
ARG is_glowroot

# can be passed during Docker build as build time environment for artifactory URL
ARG artifactory_url

# environment variable to pass active profile such as DEV, QA etc at docker runtime
ENV active_profile_env=${active_profile}

# environment variable to pass github branch to pickup configuration from, at docker runtime
ENV spring_config_label_env=${spring_config_label}

# environment variable to pass spring configuration url, at docker runtime
ENV spring_config_url_env=${spring_config_url}

# environment variable to pass glowroot, at docker runtime
ENV is_glowroot_env=${is_glowroot}

# environment variable to pass artifactory url, at docker runtime
ENV artifactory_url_env=${artifactory_url}

# environment variable to pass iam_adapter url, at docker runtime
ENV iam_adapter_url_env=${iam_adapter_url}

# can be passed during Docker build as build time environment for github branch to pickup configuration from.
ARG container_user=mosip

# can be passed during Docker build as build time environment for github branch to pickup configuration from.
ARG container_user_group=mosip

# can be passed during Docker build as build time environment for github branch to pickup configuration from.
ARG container_user_uid=1001

# can be passed during Docker build as build time environment for github branch to pickup configuration from.
ARG container_user_gid=1001

# install packages and create user
RUN apt-get -y update \
&& apt-get install -y unzip \
&& groupadd -g ${container_user_gid} ${container_user_group} \
&& useradd -u ${container_user_uid} -g ${container_user_group} -s /bin/sh -m ${container_user}

# set working directory for the user
WORKDIR /home/${container_user}

ENV work_dir=/home/${container_user}

ARG loader_path=${work_dir}/additional_jars/

RUN mkdir -p ${loader_path}

ENV loader_path_env=${loader_path}

COPY ./target/manual-verification-service-*.jar manual-verification-service.jar

# change permissions of file inside working dir
RUN chown -R ${container_user}:${container_user} /home/${container_user}

# select container user for all tasks
USER ${container_user_uid}:${container_user_gid}

EXPOSE 9002
CMD if [ "$is_glowroot_env" = "present" ]; then \
    #wget -q --show-progress "${artifactory_url_env}"/artifactory/libs-release-local/io/mosip/kernel/kernel-ref-idobjectvalidator/kernel-ref-idobjectvalidator.jar "${loader_path_env}"/kernel-ref-idobjectvalidator.jar ; \
     wget -q --show-progress "${artifactory_url_env}"/artifactory/libs-release-local/io/mosip/kernel/kernel-ref-idobjectvalidator/kernel-ref-idobjectvalidator.jar -O "${loader_path_env}"/kernel-ref-idobjectvalidator.jar ; \
	 wget -q --show-progress "${artifactory_url_env}"/artifactory/libs-release-local/icu4j/icu4j.jar -O "${loader_path_env}"/icu4j.jar ; \
	 wget -q --show-progress "${artifactory_url_env}"/artifactory/libs-release-local/icu4j/kernel-transliteration-icu4j.jar -O "${loader_path_env}"/kernel-transliteration-icu4j.jar ; \   
     wget -q --show-progress "${artifactory_url_env}"/artifactory/libs-release-local/io/mosip/testing/glowroot.zip ; \
        unzip glowroot.zip ; \
    rm -rf glowroot.zip ; \
    sed -i 's/manual-verification-service/g' glowroot/glowroot.properties ; \
#    wget -q --show-progress "${iam_adapter_url_env}" -O "${loader_path_env}"/kernel-auth-adapter.jar; \
    java -jar -Dloader.path="${loader_path_env}" -javaagent:glowroot/glowroot.jar -Dspring.cloud.config.label="${spring_config_label_env}" -Dspring.profiles.active="${active_profile_env}" -Dspring.cloud.config.uri="${spring_config_url_env}" manual-verification-service.jar ; \
    else \
          wget -q --show-progress "${artifactory_url_env}"/artifactory/libs-release-local/io/mosip/kernel/kernel-ref-idobjectvalidator/kernel-ref-idobjectvalidator.jar -O "${loader_path_env}"/kernel-ref-idobjectvalidator.jar ; \
          wget -q --show-progress "${artifactory_url_env}"/artifactory/libs-release-local/icu4j/icu4j.jar -O "${loader_path_env}"/icu4j.jar ; \
          wget -q --show-progress "${artifactory_url_env}"/artifactory/libs-release-local/icu4j/kernel-transliteration-icu4j.jar -O "${loader_path_env}"/kernel-transliteration-icu4j.jar ; \
#          wget -q --show-progress "${iam_adapter_url_env}" -O "${loader_path_env}"/kernel-auth-adapter.jar; \
          wget -q --show-progress "${virusscanner_url_env}" -O "${loader_path_env}"/kernel-virusscanner-clamav.jar; \
          java -jar -Dloader.path="${loader_path_env}" -Dspring.cloud.config.label="${spring_config_label_env}" -Dspring.profiles.active="${active_profile_env}" -Dspring.cloud.config.uri="${spring_config_url_env}" manual-verification-service.jar ; \
          #java -jar -Dloader.path="${loader_path_env}" -Dspring.cloud.config.label="${spring_config_label_env}" -Dspring.profiles.active="${active_profile_env}" -Dspring.cloud.config.uri="${spring_config_url_env}" manual-verification-service.jar ; \
      fi
