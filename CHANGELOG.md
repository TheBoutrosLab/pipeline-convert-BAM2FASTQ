# Changelog

All notable changes to pipeline-convert-BAM2FASTQ.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.1] - 2026-10-09

### Changed

- Update config submodule to fix task property access

## [1.4.0] - 2026-10-08

### Changed

- Parameterize compression level of output FASTQ files with default setting of `9`

## [1.3.1] - 2026-10-01

### Fixed

- Fix passing of reference FASTA to allow validation of CRAM input
- Allocate resources to processes to allow for parallelization where possible

## [1.3.0] - 2026-08-28

### Changed

- Tar process logs on success

## [1.2.0] - 2026-07-08

### Added

- Add Singularity containerization profile

## [1.1.0] - 2026-05-29

## [1.0.0] - 2026-05-05

### Added

- Initial version of pipeline to convert BAM/CRAM to FASTQ

[1.0.0]: https://github.com/TheBoutrosLab/pipeline-convert-BAM2FASTQ/releases/tag/v1.0.0
[1.1.0]: https://github.com/TheBoutrosLab/pipeline-convert-BAM2FASTQ/compare/v1.0.0...v1.1.0
[1.2.0]: https://github.com/TheBoutrosLab/pipeline-convert-BAM2FASTQ/compare/v1.1.0...v1.2.0
[1.3.0]: https://github.com/TheBoutrosLab/pipeline-convert-BAM2FASTQ/compare/v1.2.0...v1.3.0
[1.3.1]: https://github.com/TheBoutrosLab/pipeline-convert-BAM2FASTQ/compare/v1.3.0...v1.3.1
[1.4.0]: https://github.com/TheBoutrosLab/pipeline-convert-BAM2FASTQ/compare/v1.3.1...v1.4.0
[1.4.1]: https://github.com/TheBoutrosLab/pipeline-convert-BAM2FASTQ/compare/v1.4.0...v1.4.1
[unreleased]: https://github.com/TheBoutrosLab/pipeline-convert-BAM2FASTQ/compare/v1.4.1...HEAD
