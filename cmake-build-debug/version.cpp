#define DEF_scala_VERSION_TAG "release"
#define DEF_scala_VERSION "8.0.0"
#define DEF_scala_RELEASE_NAME "Menger"
#define DEF_scala_VERSION_FULL DEF_scala_VERSION "-" DEF_scala_VERSION_TAG
#define DEF_scala_VERSION_IS_RELEASE true

#include "version.h"

const char* const scala_VERSION_TAG = DEF_scala_VERSION_TAG;
const char* const scala_VERSION = DEF_scala_VERSION;
const char* const scala_RELEASE_NAME = DEF_scala_RELEASE_NAME;
const char* const scala_VERSION_FULL = DEF_scala_VERSION_FULL;
const bool scala_VERSION_IS_RELEASE = DEF_scala_VERSION_IS_RELEASE;
