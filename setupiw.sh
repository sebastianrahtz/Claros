echo $'EXTRA_ARGS=\"--insecure-registry docker.grapphs.com\"' | sudo tee -a /var/lib/boot2docker/profile && sudo /etc/init.d/docker restart
docker create --name researchspace-bigdata-journal -v /bigdata-data dockerfile/ubuntu
docker run --name researchspace-bigdata -d --restart=always -p 9000:8080 --env JAVA_OPTS="" --volumes-from researchspace-bigdata-journal docker.grapphs.com/bigdata
docker create --name researchspace-data docker.grapphs.com/platform-data
docker create --name researchspace-app docker.grapphs.com/app-researchspace
docker run --name researchspace-platform -d --restart=always -p 80:8080 --link researchspace-bigdata:bigdata --volumes-from researchspace-app --volumes-from researchspace-data --env PLATFORM_OPTS="-Dplatform.startPage=rsp:SearchDemo -Dplatform.repositoryType=sparql -Dplatform.endpoint=http://bigdata:8080/bigdata/sparql" docker.grapphs.com/platform
