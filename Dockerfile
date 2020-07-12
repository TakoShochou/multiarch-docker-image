FROM scratch
ARG EXE
COPY ${EXE} /multiarch/app.exe
CMD ["/multiarch/app.exe"]
